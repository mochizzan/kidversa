class HomeController < ApplicationController
  def index
  end

  def cek_assesment
    nama_lembaga = params[:lembaga]
    nisn = params[:nisn]

    data_siswa = Siswa.find_by(nisn: nisn&.strip, nama_lembaga: nama_lembaga&.strip.upcase)

    if data_siswa.present?
      redirect_to siswa_path(nama_lembaga: nama_lembaga, nisn: nisn)
    else
      redirect_to home_path
      flash[:alert] = "Data siswa tidak ditemukan. Silakan periksa kembali NISN dan nama siswa Anda."
    end
  end
end
