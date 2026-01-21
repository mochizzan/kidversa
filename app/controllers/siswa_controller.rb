class SiswaController < ApplicationController
  def index
    nisn = params[:nisn]
    nama_lembaga = params[:nama_lembaga]

    if nama_lembaga.blank? || nisn.blank?
      redirect_to home_path
      flash[:alert] = "Kesalahan Parameter Form"
      return
    end

    data_siswa = Siswa.joins(:guru).joins(:orang_tua).joins(:tahun_ajaran).find_by(nisn: nisn, nama_lembaga: nama_lembaga)

    if data_siswa.blank?
      redirect_to home_path
      flash[:alert] = "Data Siswa Tidak Ditemukan"
      return
    end

    @profile_path = data_siswa.profile_path
    @nisn = data_siswa.nisn
    @studentName = data_siswa.nama
    @kelompok_usia = data_siswa.kelompok_usia
    @tanggal_lahir = data_siswa.tanggal_lahir
    @usia = data_siswa.usia
    @guru_pembimbing = data_siswa.guru.nama
    @nama_ayah = data_siswa.orang_tua.nama_ayah
    @pekerjaan_ayah = data_siswa.orang_tua.pekerjaan_ayah
    @nama_ibu = data_siswa.orang_tua.nama_ibu
    @pekerjaan_ibu = data_siswa.orang_tua.pekerjaan_ibu
    @catatan = data_siswa.catatan
    @tahun_ajaran = data_siswa.tahun_ajaran
    @alamat = data_siswa.alamat

    @assessments = NilaiSiswa.joins(:pertanyaan).joins(:guru).where(siswa_id: data_siswa&.siswa_id)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Laporan_#{@studentName}_#{@nisn}",
               template: "layouts/sertifikat",
               formats: [ :html ],
               layout: "pdf",
               disposition: "attachment",
               orientation: "Portrait",
               page_size: "A4",
               margin: { top: 10, bottom: 10, left: 10, right: 10 }
      end
    end
  end
end
