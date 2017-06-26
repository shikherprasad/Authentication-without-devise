class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # helper_method :current_user
  # helper_method :logged_in?
  # helper_method :log_out
  # helper_method :current_user?

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:user_id]
      user = User.find_by(id: cookies.signed[:user_id])
      if user && user.authenticated?(cookies[:remember_token])
        session[:user_id] = user.id
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def current_user?(user)
    user == current_user
  end

  def new_token
    SecureRandom.urlsafe_base64
  end

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def remember(user)
    user.update_attribute(:remember_digest, digest(new_token))
    cookies.permanent.signed[:user_id] = user.id
    user.remember_token = new_token
    cookies.permanent[:remember_token] = user.remember_token
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def redirect_dest(default)
    redirect_to (session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

end
