# Geolocation with currency converter

*Note: I added comments to the actual code in the repo for readability.*

## Implementation
 - [x] Added currency column to user model
 - [x] Change currency based on geolocation
 - [x] Filter the currency from geolocation (if client's currency is not supported, default to USD)
 - [x] Persist the currency change if the user changes the location
 - [x] Set default currency in Ad create

### Add currency to user devise model

I added a migration to add a column named `currency`. This is where the persisted currency code will be stored. This is default to nil.

If user's currency is nil, it will base the currency on the detected location. Otherwise, it will use the persisted data to determine the currency to be used.

```
class AddLocationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :currency, :string, default: nil, allow_nil: true
  end
end
```

### Change currency based on geolocation

I used `geocoder` gem to get the client's country: https://github.com/alexreisner/geocoder

**Note: Geocoder does not work on development environment (since no ip and only localhost). So I deployed the repo to heroku. Below is the link to it.**

 🖥 Development Link: https://mylab-geolocation-test.herokuapp.com/

*I had to change the currency bank api to `eu_central_bank` since my api request to `currencylayer` has reached the max limit. I also only was able to test this on a number of countries because of the limit of my free vpn since it does not support countries in africa. But this should work regardless.*

To implement this, I added a `set_currency` in ApplicationController. This is then called as a before_action on Ads controller for index, show, create.

```
  def set_currency
    if current_user.currency.nil?
      if Rails.env.production?
        @country_code = request.location.country
        @city = request.location.city
        @country_details = Country.new(@country_code)
        @country_name = @country_details.name
        @currency_code = @country_details.currency_code
      end
  end
```

As stated before: If user's currency is nil, it will base the currency on the geolocation. Otherwise, it will use the persisted data to determine the currency to be used.

**The currency based on geolocation is not persisted. The currency will only be persisted if the user choose from the dropdown.**


### Filter the currency from geolocation

To only allow currencies that is supported by the application, I added a service object. This filters out the currency. It checks whether the currency is supported by the application, if not, it sets it to the default currency.

I added a service object that will filter the currencies. Set all the currencies that will be supported by the application in `@supported_currencies`

```
class FilterCurrency
  def initialize(currency_code)
    @currency_code = currency_code
    @default_currency = "USD"
    @supported_currencies = %w[USD PHP EUR JPY]
  end

  def perform
    return @default_currency unless @supported_currencies.include? @currency_code

    @currency_code
  end
end

```

Then `set_currency` is updated to use the filter_currency service object in setting `session[:currency]`

```
def set_currency
  if current_user.id.nil? || current_user.location.nil?
      if Rails.env.production?
        ...
        @filtered_currency = FilterCurrency.new(@currency_code).perform

        if session[:set_currency].nil?
          session[:currency] = @filtered_currency
        else
          session[:currency] = session[:set_currency]
        end
      end
    else
      session[:currency] = if current_user.id.nil?
                             params[:currency]
                           else
                             current_user.currency
                           end
    end
```

### Persist the currency change if the user changes the location

The currency column is default set to nil. **Currency column will only have value once the user changes the currency from the dropdown menu.**

The currency is only persisted if the user is logged in, otherwise, it will use the session currency.

To implement this, I updated `save_currency` in ads_controller and `set_currency` in application controller.

```
  def save_currency
    session[:set_currency] = params[:currency]
    current_user.update(currency: params[:currency])

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
    end
  end

```

```
  def set_currency
    if current_user.id.nil? || current_user.currency.nil?
      if Rails.env.production?
        ...
        session[:currency] = @filtered_currency if session[:set_currency].nil?
      end
    else
      session[:currency] = current_user.currency
    end
  end
```

### Set default currency in Ad create

I updated before_action `set_currency` to include `new`. Then set a default value to currency select in ads form.

```
before_action :set_currency, only: %i[index show create new]
```

```
<%= f.select :price_currency, [["USD- US Dollars", "USD"],
                                 ["JPY- Japanese Yen", "JPY"],
                                 ["PHP - Philippine Peso", "PHP"],
                                 ["EUR - European Pound", "EUR"]],
                                 selected: session[:currency] %>
```

# Currency and Language Internalization

## Changes

- [x] Switch language
- [x] Switch currency
- [x] Choose currency in creating ad (price)

### Language Implementation

I used the ruby gem I18n to implement switching of languages based on user input.
I added a dropdown link in the navigation bar with links to different languages the user can choose from.

```
<%= link_to "English", url_for(locale: "en") %>
<%= link_to "Spanish", url_for(locale: "es") %>
<%= link_to "Japanese", url_for(locale: "ja") %>
```

In application_controller, I added a private method to set the locale based on the language chosen by the user. This private method will be called before every action made.

```
before_action :set_locale

...

private

def set_locale
  I18n.locale = params[:locale] || I18n.default_locale
end

def default_url_options(_options = {})
  { locale: I18n.locale }
end
```

To persist the chosen language, I modified the routes to have a locale.

```
scope "(:locale)" do
  ...
end
```

To translate the static strings in the app, a .yml file is used to store all the different strings for different languages. These files are stored in `config/locales`.

For example:

en.yml - English

```
en:
  language_name: "English"
  marketplace:
    title: "Marketplace"
    listing: "Latest Listing"
```

ja.yml - Japanese

```
ja:
  language_name: "Japanese"
  marketplace:
    title: "市場リスト"
    listing: "最新のリスト"
```

es.yml - Spanish

```
es:
  language_name: "Spanish"
  marketplace:
    title: "Listado de mercado"
    listing: "Listado más reciente"
```

Then in the view, modify the static strings to reference the configurations in the yml for that language.

In ad index:

```
<p><%= t "marketplace.title" %></p>
<h4><%= t "marketplace.listing" %></h4>
```

Note: You have to manually input all the strings in different languages in the yml file. Also, I included the gem devise I18n to support the languages for devise controller.


### Currency Implementation

To implement the support for different currencies, I used these gems:

```
gem "eu_central_bank"
gem "json"
gem "money-rails"
```

Note: I initially used google-currency for the conversion but by the time I was converting the prices, I found out that it is no longer supported and already deprecated. So I decided to use eu_central_bank to convert the price to different currencies.

I added the configuration for money-rails and set the default bank to use EuCentralBank (config/initializers/money.rb)

```
require "money"
require "eu_central_bank"

MoneyRails.configure do |config|
  config.default_currency = :usd

  # set default bank to instance of EuCentralBank
  Money.default_bank = EuCentralBank.new
end

```

I added a migration to make monetize the price in ad. I dropped the price column and did the migration below:

```
  def change
    remove_column :ads, :price
    add_monetize :ads, :price
  end
```
This adds columns `price_cents` and `price_currency`. The price will be stored as cents and will then be converted when the Money gem is used to call the price in the view. Cents is used to get accurate value across different currencies.
Reference: https://github.com/RubyMoney/money-rails

In the controller and routes, I added save_currency to persist the currency the user chose.

```
  def save_currency
    session[:currency] = params[:currency]
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
    end
  end
```

```
post "ads/save_currency", to: "ads#save_currency"
```

I added these in the ad model:

```
  monetize :price_cents

  def price
    Money.new price_cents, price_currency
  end
```

Then I added an application_helper for price currency conversion:

```
  def converted_price(price)
    Money.default_bank.update_rates

    if session[:currency].present?
      humanized_money_with_symbol(Money.default_bank.exchange_with(price, session[:currency]))
    else
      humanized_money_with_symbol(price)
    end
  end
```

Note: Update the rates before converting for accurate data.

To output the price in the view:

```
<%= converted_price(ad.price) %></a>
```

In the view for create ad: I modified the input to price_cents and added select for price_currency.
To convert the price input to cents:

```
def create
    @ad = current_user.ads.build(ad_params)
    @ad.price_cents = params[:ad][:price].to_money.cents //added this

   ...
  end
```
