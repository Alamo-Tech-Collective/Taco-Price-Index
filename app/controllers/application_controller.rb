class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  helper_method :current_user
  
  private
  
  def current_user
    Current.user
  end
  
  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You don't have permission to access this page."
    end
  end
end
