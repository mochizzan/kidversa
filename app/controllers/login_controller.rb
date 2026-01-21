class LoginController < ApplicationController
  before_action :check_session, except: [ :destroy ]
  def index
  end

  def create
    username = params[:username]
    password = params[:password]

    if username.blank? || password.blank?
      flash[:alert] = "Username and password cannot be blank"
      render :index
    else
      user = User.select(:user_id, :username, :password_digest, :role).find_by(username: username)

      if user && user.authenticate(password)
        session[:user_id] = user.user_id
        session[:username] = user.username
        redirect_to admin_path
        flash[:notice] = "Login Berhasil"
      else
        redirect_to login_path
        flash[:alert] = "Periksa Kembali Username dan Password Anda"
      end
    end
  end

  def destroy
    puts "Logging out user with ID: #{session[:user_id]}"
    session.delete(:user_id)
    session.delete(:username)
    session.clear
    redirect_to login_path
  end

  private
  def check_session
    user_id = session[:user_id]
    if user_id.present?
      redirect_to admin_path
    end
  end
end
