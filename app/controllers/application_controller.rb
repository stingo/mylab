class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale, except: [:configure_permitted_parameters]

  include CurrentUserConcern

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:username, :first_name, :last_name, :email,
                         :password, :password_confirmation)
    end

    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit(:username, :first_name, :last_name, :email,
                         :password, :password_confirmation)
    end
  end

  def set_location
    if current_user.id.nil? || current_user.location.nil?
      if Rails.env.production?
        @country = request.location.country
        country_details = Country.find_country_by_name(@country)
        # @currency = country_details.currency['code']
        @city = request.location.city
        @country_code = request.location.country_code
      end
    else
      @country = current_user.location
    end
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(_options = {})
    { locale: I18n.locale }
  end
end
