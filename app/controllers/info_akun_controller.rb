class InfoAkunController < ApplicationController
  before_action :check_session

  def index
    @user = User.find_by(user_id: session[:user_id])
  end

  def update_password
    @user = User.find_by(user_id: session[:user_id])
    if params[:password].blank? || params[:password_confirm].blank?
      flash[:alert] = "Password tidak boleh kosong"
      redirect_to info_akun_index_path
      return
    end

    if params[:password] != params[:password_confirm]
      flash[:alert] = "Password dan Konfirmasi Password tidak cocok"
      redirect_to info_akun_index_path
      return
    end

    if @user.update(password: params[:password])
      flash[:notice] = "Password berhasil diubah"
    else
      flash[:alert] = "Gagal mengubah password"
    end
    redirect_to info_akun_index_path
  end

  private

  def check_session
    unless session[:user_id].present?
      flash[:alert] = "Anda harus login terlebih dahulu"
      redirect_to login_path
    end
  end
end
