class InfoPribadiController < ApplicationController
  before_action :check_session

  def index
    @user = User.find_by(user_id: session[:user_id])
    @guru = @user&.guru
    if @guru.nil?
      flash[:alert] = "Data profil Guru tidak ditemukan"
      redirect_to root_path
    end
  end

  def update
    @user = User.find_by(user_id: session[:user_id])
    @guru = @user&.guru

    if @guru
      if @guru.update(guru_params)
        flash[:notice] = "Informasi pribadi berhasil diperbarui"
      else
        flash[:alert] = "Gagal memperbarui informasi pribadi: #{@guru.errors.full_messages.join(', ')}"
      end
    else
      flash[:alert] = "Gagal memperbarui: Data guru tidak ditemukan."
    end
    redirect_to info_pribadi_index_path
  end

  private

  def check_session
    unless session[:user_id].present?
      flash[:alert] = "Anda harus login terlebih dahulu"
      redirect_to login_path
    end
  end

  def guru_params
    params.require(:guru).permit(
      :nama_sekolah, :alamat_sekolah, :nama, :nik, :jenis_kelamin,
      :tempat_lahir, :tanggal_lahir, :nama_ibu_kandung, :agama, :alamat_tempat_tinggal,
      :npwp, :nama_wajib_pajak, :kewarganegaraan, :status_perkawinan
    )
  end
end
