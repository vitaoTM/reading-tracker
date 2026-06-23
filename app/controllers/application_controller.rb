class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def eink_mode?
    return params[:eink] == "1" if params[:eink].present?
    user_signed_id? && current_user.eink_mode?
  end

  helper_method :eink_mode?

  private

  def user_signed_id?
    Current.user.present?
  end

  def current_user
    Current.user
  end
end
