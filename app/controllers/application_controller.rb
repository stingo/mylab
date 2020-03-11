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
        @country_code = request.location.country # To get client's country
        @city = request.location.city # To get city name of the client (may remove this, for debugging only)
        @country_details = Country.new(@country_code) # create a country object from country code to get country details
        @country_name = @country_details.name # To get country name (may remove this, for debugging only)
        @currency_code = @country_details.currency_code # To get currency code
        # @filtered_currency = FilterCurrency.new(@currency_code) # This calls the service object and determines whether the currency code is supported

        session[:currency] = @currency_code
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
