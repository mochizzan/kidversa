class PenilaianController < AdminController
  def index
    user_id = session[:user_id]
    siswa_id = params[:siswa_id]
    @data_akun = User.find_by(user_id: user_id)

    @data_siswa = Siswa.find_by(siswa_id: siswa_id)
    @data_pertanyaan = Pertanyaan.all
    @data_guru = Guru.all
    @data_nilai = NilaiSiswa.joins(:guru).joins(:pertanyaan).where(siswa_id: siswa_id)
  end

  def simpan_penilaian
    guru_id = params[:guru_id]
    pertanyaan_id = params[:pertanyaan_id]
    siswa_id = params[:siswa_id]

    ta_aktif = TahunAjaran.find_by(is_active: 1)

    nilai = nil
    bb = params[:nilai_0]
    mb = params[:nilai_1]
    bsh = params[:nilai_2]
    bsb = params[:nilai_3]

    if bb.present?
      nilai = bb
    elsif mb.present?
      nilai = mb
    elsif bsh.present?
      nilai = bsh
    elsif bsb.present?
      nilai = bsb
    end

    current_nilai = NilaiSiswa.find_by(pertanyaan_id: pertanyaan_id, siswa_id: siswa_id)
    if current_nilai
      current_nilai.update(nilai: nilai, guru_id: guru_id)
      flash[:notice] = "Penilaian berhasil diperbarui."
      redirect_to penilaian_path(siswa_id: siswa_id)
    else
      nilai_siswa = NilaiSiswa.new(
      siswa_id: siswa_id,
      guru_id: guru_id,
      nilai: nilai,
      pertanyaan_id: pertanyaan_id,
      tahun_ajaran_id: ta_aktif.id
    )
      if nilai_siswa.save
        flash[:notice] = "Penilaian berhasil disimpan."
        redirect_to penilaian_path(siswa_id: siswa_id)
      else
        flash[:alert] = "Penilaian gagal disimpan."
        redirect_to penilaian_path(siswa_id: siswa_id)
      end
    end

    total_pertanyaan = Pertanyaan.count
    total_nilai_siswa = NilaiSiswa.where(siswa_id: siswa_id).count

    current_status_nilai = StatusPenilaian.find_by(siswa_id: siswa_id, tahun_ajaran_id: ta_aktif.id)

    if total_nilai_siswa >= total_pertanyaan
      if current_status_nilai
        StatusPenilaian.find_by(siswa_id: siswa_id, tahun_ajaran_id: ta_aktif.id).update(status: Time.now)
      else
        StatusPenilaian.create(
        siswa_id: siswa_id,
        tahun_ajaran_id: ta_aktif.id
      )
      end
    end
  end

  def reset_penilaian
    siswa_id = params[:siswa_id]
    pertanyaan_id = params[:pertanyaan_id]

    current_nilai = NilaiSiswa.find_by(pertanyaan_id: pertanyaan_id, siswa_id: siswa_id)

    if current_nilai
      current_nilai.delete
    end

    redirect_to penilaian_path(siswa_id: siswa_id)
    flash[:notice] = "Penilaian berhasil direset."
  end
end
