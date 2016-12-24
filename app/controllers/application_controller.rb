class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    if current_admin
      flash[:alert] = "Access to that page has been denied."
      redirect_to root_path
    else
      flash[:notice] = "Please log in to access that page."
      redirect_to new_admin_session_path
    end
  end

  def after_sign_in_path_for(resource)
    admin_home_path
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin, session)
  end
end
