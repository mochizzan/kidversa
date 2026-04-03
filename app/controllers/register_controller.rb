class RegisterController < ApplicationController
  def index
    @lembagas = Lembaga.select(:nama_lembaga).where.not(nama_lembaga: [nil, '']).distinct
  end

  def daftar
    ActiveRecord::Base.transaction do
      begin
        lembaga = Lembaga.find_or_create_by!(nama_lembaga: params[:nama_sekolah])

        guru = Guru.create!(
          lembaga_id: lembaga.lembaga_id,
          nama: params[:nama_lengkap], # Adjusted based on their sql
          alamat_sekolah: params[:alamat_sekolah],
          nik: params[:nik],
          jenis_kelamin: params[:jenis_kelamin],
          tempat_lahir: params[:tempat_lahir],
          tanggal_lahir: params[:tanggal_lahir],
          nama_ibu_kandung: params[:nama_ibu_kandung],
          agama: params[:agama],
          alamat_tempat_tinggal: params[:alamat_tempat_tinggal],
          npwp: params[:npwp],
          nama_wajib_pajak: params[:nama_wajib_pajak],
          kewarganegaraan: params[:kewarganegaraan],
          status_perkawinan: params[:status_perkawinan]
        )

        User.create!(
          guru_id: guru.guru_id,
          username: params[:username],
          password: params[:password],
          role: 1
        )

        flash[:notice] = "Akun berhasil dibuat"
        redirect_to login_path
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = "Pendaftaran gagal: #{e.record.errors.full_messages.join(', ')}"
        redirect_to register_path
      end
    end
  end
end
