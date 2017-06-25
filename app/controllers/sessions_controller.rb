class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      remember user
      redirect_dest user
    else
      render 'new'
    end
  end

  def destroy
    if logged_in?
      current_user.update_attribute(:remember_digest, nil)
      cookies.delete(:user_id)
      cookies.delete(:remember_token)
      session.delete(:user_id)
      @current_user = nil
    end
    redirect_to root_url

  end

end
