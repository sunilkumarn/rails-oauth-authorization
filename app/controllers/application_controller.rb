class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :require_login
  helper_method :current_user, :logged_in?

  private

  def require_login
    gon_setup
    unless logged_in?
      redirect_to root_path
    end
  end

  def logged_in?
    !!current_user
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

end
