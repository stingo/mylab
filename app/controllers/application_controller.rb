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

  def set_currency
    if Rails.env.production?
      @country_code = request.location.country_code
      @country_details = Country.new(@country_code)
      @currency_code = @country_details.currency_code
      @filtered_currency = FilterCurrency.new(@currency_code).perform
    end

    session[:currency] = if current_user.currency.nil?
                           if session[:set_currency].nil?
                             @filtered_currency
                           else
                             session[:set_currency]
                                                end
                         else
                           if current_user.id.nil?
                             params[:currency]
                           else
                             current_user.currency
                                                end
                         end
  end

  def update_currency_rate
    return unless MoneyRails.default_bank.expired?

    MoneyRails.default_bank.update_rates
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(_options = {})
    { locale: I18n.locale }
  end
end
