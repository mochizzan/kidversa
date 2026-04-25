class AdminController < ApplicationController
  before_action :auth
  def index
    data_user = User.find_by(user_id: session[:user_id])
    data_guru = Guru.find_by(guru_id: data_user.guru_id)

    @tahun_ajaran_aktif = TahunAjaran.find_by(is_active: 1)
    @semua_tahun_ajaran = TahunAjaran.order(id: :desc)

    @total_siswa = Siswa.where(tahun_ajaran_id: @tahun_ajaran_aktif.id).count
    @total_pertanyaan = Pertanyaan.where(tahun_ajaran_id: @tahun_ajaran_aktif).count

    @nama_guru = data_guru.nama

    start_date = Date.today.beginning_of_week
    end_date = Date.today.end_of_week

    @total_dinilai_minggu_ini = StatusPenilaian.where(status: Time.now.beginning_of_week..Time.now.end_of_week).count

    penilaian_minggu_ini = StatusPenilaian.where(status: start_date..end_date).group("DATE(status)").count

    @data_grafik = (start_date..end_date).map do |date|
      penilaian_minggu_ini[date.to_s] || penilaian_minggu_ini[date] || 0
    end
  end

  def data_siswa
    data_user = User.find_by(user_id: session[:user_id])
    unless data_user && data_user.guru_id
      redirect_to login_path, alert: "Sesi tidak valid." and return
    end

    guru = Guru.find_by(guru_id: data_user.guru_id)
    @nama_guru = guru&.nama

    @ta_aktif_obj = TahunAjaran.find_by(is_active: 1)

    if @ta_aktif_obj.nil?
      @tahun_ajaran_aktif = "Tidak Ada T.A Aktif"
      @siswas = Siswa.none.page(params[:page])
      @siswa_lama = []
      flash.now[:alert] = "Harap set tahun ajaran aktif di menu pengaturan."
      return
    end

    @tahun_ajaran_aktif = @ta_aktif_obj.nama
    scope = Siswa.joins(:riwayats).where(riwayat: { tahun_ajaran_id: @ta_aktif_obj.id })

    if params[:search].present?
      keyword = "%#{params[:search]}%"
      scope = scope.where("siswa.nisn LIKE ? OR siswa.nama LIKE ?", keyword, keyword).distinct
    end

    @siswas = scope.order(nama: :asc).page(params[:page]).per(25)

    ids_siswa_aktif = Riwayat.where(tahun_ajaran_id: @ta_aktif_obj.id).pluck(:siswa_id)
    @siswa_lama = Siswa.where.not(siswa_id: ids_siswa_aktif).order(nama: :asc)
    @lembagas = Lembaga.select(:nama_lembaga).where.not(nama_lembaga: [nil, '']).distinct
  end

  def tambah_data_siswa
    data_siswa = params[:data_siswa]

    nama_guru = data_siswa[:nama_guru]
    guru_id = nil
    if nama_guru.present?
      guru_id = Guru.find_by(nama: nama_guru.strip.downcase).guru_id
    end

    profile_path = nil
    if data_siswa[:profile_path].present?
      profile_path = upload_foto(data_siswa[:profile_path])
    end

    if profile_path.nil?
      redirect_to data_siswa_path
      return
    end

    orang_tua_id = SecureRandom.uuid
    @orang_tua = OrangTua.new(
      orang_tua_id: orang_tua_id,
      nama_ayah: data_siswa[:nama_ayah],
      nama_ibu: data_siswa[:nama_ibu],
      pekerjaan_ayah: data_siswa[:pekerjaan_ayah],
      pekerjaan_ibu: data_siswa[:pekerjaan_ibu]
    )

    lembaga = Lembaga.find_or_create_by!(nama_lembaga: data_siswa[:nama_lembaga])

    @siswa = Siswa.new(
      nisn: data_siswa[:nisn],
      nama: data_siswa[:nama],
      tanggal_lahir: data_siswa[:tanggal_lahir],
      usia: data_siswa[:usia],
      kelompok_usia: data_siswa[:kelompok_usia],
      lembaga_id: lembaga.lembaga_id,
      alamat: data_siswa[:alamat],
      guru_id: guru_id,
      profile_path: profile_path,
      tahun_ajaran_id: TahunAjaran.find_by(is_active: true)&.id,
      orang_tua_id: orang_tua_id
    )

    if @orang_tua.save && @siswa.save
      ta_aktif = TahunAjaran.find_by(is_active: true)
      Riwayat.create(siswa_id: @siswa.siswa_id, tahun_ajaran_id: ta_aktif.id) if ta_aktif
      redirect_to data_siswa_path, notice: "Data berhasil disimpan!"
    else
      redirect_to data_siswa_path, alert: "Gagal menyimpan data."
    end
  end

  def edit_data_siswa
    siswa_id = params[:siswa_id]
    data_siswa = Siswa.find_by(siswa_id: siswa_id)
    data_orang_tua = OrangTua.find_by(orang_tua_id: data_siswa.orang_tua_id)

    profile_path = data_siswa.profile_path
    if params[:profile_path].present?
      profile_path = upload_foto(params[:profile_path])
    end

    if data_orang_tua
      data_orang_tua.update(
          nama_ayah: params[:nama_ayah],
          nama_ibu: params[:nama_ibu],
          pekerjaan_ayah: params[:pekerjaan_ayah],
          pekerjaan_ibu: params[:pekerjaan_ibu]
        )
    else
      orang_tua_id = SecureRandom.uuid
      OrangTua.create(
        orang_tua_id: orang_tua_id,
        nama_ayah: params[:nama_ayah],
        nama_ibu: params[:nama_ibu],
        pekerjaan_ayah: params[:pekerjaan_ayah],
        pekerjaan_ibu: params[:pekerjaan_ibu]
      )
      data_siswa.update(orang_tua_id: orang_tua_id)
    end

    if data_siswa
      lembaga = Lembaga.find_or_create_by!(nama_lembaga: params[:nama_lembaga])

      data_siswa.update(
        nisn: params[:nisn],
        nama: params[:nama],
        tanggal_lahir: params[:tanggal_lahir],
        usia: params[:usia],
        kelompok_usia: params[:kelompok_usia],
        lembaga_id: lembaga.lembaga_id,
        alamat: params[:alamat],
        profile_path: profile_path
        )
    end

    redirect_to data_siswa_path, notice: "Data berhasil diupdate!"
  end

  def hapus_data_siswa
    siswa_id = params[:siswa_id]
    data_siswa = Siswa.find_by(siswa_id: siswa_id)

    if data_siswa
      orang_tua_id = data_siswa.orang_tua_id
      
      # Siswa wajib di destroy lebih dulu karena orang_tua_id direferensikan oleh tabel Siswa
      # Serta agar relasi nilai, riwayat, dan status penilaian ikut terhapus
      data_siswa.destroy
      
      if orang_tua_id.present?
         OrangTua.find_by(orang_tua_id: orang_tua_id)&.destroy
      end
      redirect_to data_siswa_path, notice: "Data berhasil dihapus!"
    else
      redirect_to data_siswa_path, alert: "Data tidak ditemukan."
    end
  end

  def migrasi_data_siswa
    siswa_ids = params[:siswa_ids]
    target_kelompok = params[:target_kelompok]
    nama_lembaga = params[:nama_lembaga]
    ta_aktif = TahunAjaran.find_by(is_active: true)

    if ta_aktif.nil?
      redirect_to data_siswa_path, alert: "Tidak ada tahun ajaran aktif!" and return
    end

    if siswa_ids.present?
      ActiveRecord::Base.transaction do
        siswa_ids.each do |id|
          siswa = Siswa.find_by(siswa_id: id)
          next unless siswa

          update_params = {}
          update_params[:kelompok_usia] = target_kelompok if target_kelompok.present?
          if nama_lembaga.present?
            lembaga = Lembaga.find_or_create_by!(nama_lembaga: nama_lembaga)
            update_params[:lembaga_id] = lembaga.lembaga_id
          end
          update_params[:tahun_ajaran_id] = ta_aktif[:id]

          siswa.update(update_params) if update_params.any?

          sudah_terdaftar = Riwayat.exists?(siswa_id: siswa.siswa_id, tahun_ajaran_id: ta_aktif.id)

          unless sudah_terdaftar
            Riwayat.create!(
              siswa_id: siswa.siswa_id,
              tahun_ajaran_id: ta_aktif.id
            )
          end
        end
      end
      flash[:notice] = "Berhasil memigrasikan #{siswa_ids.count} siswa ke T.A #{ta_aktif.nama}"
    else
      flash[:alert] = "Tidak ada siswa yang dipilih."
    end

    redirect_to data_siswa_path
  end





  def data_pertanyaan
    @tahun_ajaran_aktif = TahunAjaran.find_by(is_active: 1)
    @data_pertanyaan = Pertanyaan.where(tahun_ajaran_id: @tahun_ajaran_aktif.id)
  end

  def tambah_data_pertanyaan
    isi = params[:isi]
    ta_aktif_id = TahunAjaran.find_by(is_active: 1).id

    pertanyaan = Pertanyaan.new(
      tahun_ajaran_id: ta_aktif_id,
      nama_pertanyaan: isi,
    )

    if pertanyaan.save
      flash[:notice] = "Data berhasil disimpan!"
      redirect_to data_pertanyaan_path
    else
      flash[:alert] = "Gagal menyimpan data."
      redirect_to data_pertanyaan_path
    end
  end

  def edit_data_pertanyaan
    pertanyaan_id = params[:pertanyaan_id]
    isi = params[:isi]

    pertanyaan = Pertanyaan.find_by(pertanyaan_id: pertanyaan_id)
    if pertanyaan.present?
      pertanyaan.update(nama_pertanyaan: isi)
      flash[:notice] = "Data berhasil diupdate!"
      redirect_to data_pertanyaan_path
    else
      flash[:alert] = "Data tidak ditemukan."
      redirect_to data_pertanyaan_path
    end
  end

  def delete_data_pertanyaan
    pertanyaan_id = params[:pertanyaan_id]

    pertanyaan = Pertanyaan.find_by(pertanyaan_id: pertanyaan_id)
    if pertanyaan.present?
      pertanyaan.delete
      flash[:notice] = "Data berhasil dihapus!"
      redirect_to data_pertanyaan_path
    else
      flash[:alert] = "Data tidak ditemukan."
      redirect_to data_pertanyaan_path
    end
  end




  def data_nilai
    search = params[:search]
    ta_aktif = TahunAjaran.find_by(is_active: 1)
    scope = Siswa.where(tahun_ajaran_id: ta_aktif.id).order(nama: :asc)
    if search.present?
      keyword = "%#{search}%"
      scope = scope.where("nisn LIKE ? OR nama LIKE ?", keyword, keyword)
    end
    @data_siswa = scope.page(params[:page]).per(25)
    @total_pertanyaan = Pertanyaan.all.count
    @nilai_siswa = NilaiSiswa.all
  end

  def simpan_catatan
    isi_catatan = params[:isi_catatan]
    siswa_id = params[:siswa_id]

    siswa = Siswa.find_by(siswa_id: siswa_id)
    if siswa.present?
      siswa.update(catatan: isi_catatan)
      flash[:notice] = "Catatan berhasil disimpan!"
      redirect_to data_nilai_path
    else
      flash[:alert] = "Data tidak ditemukan."
      redirect_to data_nilai_path
    end
  end




  def upload_foto(file_io)
    if file_io.size < 3.megabyte
      nisn = params.dig(:data_siswa, :nisn) || params[:nisn]
      extension = File.extname(file_io.original_filename)
      file_name = "profile_#{nisn}#{extension}"
      file_path = Rails.root.join("public", "uploads")
      FileUtils.mkdir_p(file_path) unless File.exist?(file_path)

      # Hapus file lama jika ada yang namanya mirip (karena ekstensi mungkin beda)
      Dir.glob(File.join(file_path, "profile_#{nisn}.*")).each do |f|
        File.delete(f)
      end

      File.open(File.join(file_path, file_name), "wb") do |file|
        file.write(file_io.read)
      end
      "/uploads/#{file_name}".to_s
    else
      flash[:alert] = "Ukuran file terlalu besar. Harus Kurang dari 3MB."
      nil
    end
  end

  def tambah_tahun_ajaran
    nama_baru = params[:nama_tahun_ajaran]

    if nama_baru.present?
      TahunAjaran.create(nama: nama_baru, is_active: false)
      flash[:notice] = "Tahun ajaran baru berhasil ditambahkan."
    else
      flash[:alert] = "Nama tahun ajaran tidak boleh kosong."
    end
    redirect_to admin_path
  end

  def ganti_tahun_ajaran_aktif
    id_tahun_baru = params[:tahun_ajaran_id]

    TahunAjaran.transaction do
      TahunAjaran.update_all(is_active: 0)
      tahun_pilihan = TahunAjaran.find_by(id: id_tahun_baru)
      if tahun_pilihan
        tahun_pilihan.update(is_active: 1)
        flash[:notice] = "Tahun ajaran aktif berhasil diganti ke #{tahun_pilihan.nama}"
      end
    end

    redirect_to admin_path
  rescue => e
    flash[:alert] = "Gagal mengganti tahun ajaran."
    redirect_to admin_path
  end

  def auth
    user_id = session[:user_id]
    username = session[:username]

    puts user_id

    if user_id.nil? || username.nil?
      redirect_to login_path
    end
  end
end
