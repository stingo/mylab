# Bug Fixes

## Changes
- [x] Fix for country_code nil error
- [x] Exclude currency dropdown of forgotten password page

Deployed the changes to a new staging environment: https://upfrica-develop.herokuapp.com/

### Exclude currency dropdown of forgotten password page

In the nav file (/app/views/shared/guest_nav.html.erb), I updated the unless clause for currency dropdown to this:
```
<% unless controller_name == "sessions" || controller_name == "passwords"  %>
  <li class="nav-item dropdown">
    <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><%= "#{Money.new(10, session[:currency]).symbol} #{session[:currency]}" %></a>
    <div class="dropdown-menu" aria-labelledby="navbarDropdown">
      <%= button_to "$ USD", { controller: "ads", action: "save_currency", currency: "USD" }, method: :post, class: "dropdown-item" %>
      <%= button_to "₱ PHP", { controller: "ads", action: "save_currency", currency: "PHP" }, method: :post, class: "dropdown-item" %>
      <%= button_to "¥ JPY", { controller: "ads", action: "save_currency", currency: "JPY" }, method: :post, class: "dropdown-item" %>
      <%= button_to "€ EUR", { controller: "ads", action: "save_currency", currency: "EUR" }, method: :post, class: "dropdown-item" %>
    </div>
  </li>
<% end %>
```
Should now work for forgotten password page and login. If the issue persist to other pages/controllers, just add the controller name in the conditional.

### Fix for country_code nil error

In application_controller (/app/controllers/application_controller.rb), I updated the code to the following:

```
def set_currency
  if Rails.env.production?
    @country_code = request.location.country_code
    @country_details = Country.new(@country_code)
    @currency_code = @country_details.currency_code
    @filtered_currency = FilterCurrency.new(@currency_code).perform
  end

  if current_user.currency.nil?
    session[:currency] = if session[:set_currency].nil?
                           @filtered_currency
                         else
                           session[:set_currency]
                         end
  else
    session[:currency] = if current_user.id.nil?
                           params[:currency]
                         else
                           current_user.currency
                         end
  end
end
```

# Refactor CurrencyLayer API Implementation

## Changes
- [x] Replicated the production tables
- [x] Added caching for CurrencyLayer rates
- [x] Removed currency reference in ads
- [x] Added scope for currency show ads (a link_to from each Ad to currency)

### Replicated production table and view

I added a currency table and referenced it in ads table. These are the migrations I did
```
class CreateCurrency < ActiveRecord::Migration[6.0]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :country
      t.string :iso_code
      t.string :website
    end
  end
end
```
```
class AddCurrencyReferenceToAds < ActiveRecord::Migration[6.0]
  def up
    add_reference :ads, :currency, default: 1, null: false, foreign_key: true
  end

  def down
    remove_reference :ads, :currency
  end
end
```

Then I added currency controller and view for index and show for the currency list:

```
class CurrenciesController < ApplicationController
  def index
    @currencies = Currency.all
  end

  def show
    currency = Currency.find(params[:id])
    @ads = Ad.all.currency_ads(currency.iso_code)
  end
end
```

Those are the migrations I did to be able to replicate your current production version

### Added caching for currencylayer

I modified the currencylayer implementation. I used a different gem to be able to use currencylayer.

In the gemfile:
```
gem "money-currencylayer-bank"
```

To limit the API requests, we talked about persisting the rates, however, I think caching the returned rates by the currencylayer is a better approach. The expire time of it is 86400 seconds or 24 hours.

In initialization of Money (config/initializers/money.rb):
```
require "money/bank/currencylayer_bank"

MoneyRails.configure do |config|
  Money.default_currency = "USD"
  bank = Money::Bank::CurrencylayerBank.new
  bank.access_key = "749ea9046a7bd8b11d3e155d0acfdb19"
  bank.source = "USD"
  bank.ttl_in_seconds = 86_400
  bank.cache = proc do |v|
    key = "money:currencylayer_bank"
    if v
      Thread.current[key] = v
    else
      Thread.current[key]
    end
  end

  config.default_bank = bank
end
```

Then I removed update of rates in AdsHelper (app/helpers/ads_helper.rb):
```
module AdsHelper
  def converted_price(price)
    if session[:currency].present?
      humanized_money_with_symbol(Money.default_bank.exchange_with(price, session[:currency]))
    else
      humanized_money_with_symbol(price)
    end
  end
end
```
I moved the rate update to application_controller in case you need it for other controllers other that ads (app/controllers/application_controller.rb):

```
def update_currency_rate
  return unless MoneyRails.default_bank.expired?

  MoneyRails.default_bank.update_rates
end
```

Then in ads_controller, I added a before_action to update the rates in the controllers that will need rate conversions (app/controllers/ads_controller.rb):
```
before_action :update_currency_rate, only: [:index, :show]
```

I tested this and kept track of the API usage in currencylayer. I added ads, refereshed the pages, changed the currencies and it did not add count to the API usage. If you will check the API usage count right after deploying or running the app, you will see in the first few minutes that it is making some requests to the API since it is still initializing. But after a while, there will be no more additional API requests. I haven't tested if it will update the rates after 86,400 seconds since I have to have the development server running for a while. But this should be good to go.

### Removed currency reference in ads

To de-associate the currency from the ads, I created a migration that will move the `currency` column in the ad to the `price_currency` column and remove the reference currency:

```
class RemoveCurrencyReferenceInAds < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::Base.transaction do
      Ad.all.each do |ad|
        currency = Currency.find_by(id: ad.currency_id)
        ad.update(price_currency: currency.iso_code)
      end
    end

    remove_reference :ads, :currency
  end
  def down
    add_reference :ads, :currency, default: 1, null: false, foreign_key: true

    ActiveRecord::Base.transaction do
      Ad.all.each do |ad|
        price_currency = Currency.find_by(iso_code: ad.price_currency)
        ad.update(currency: price_currency.id)
      end
    end
  end
end
```

This should de-associate the currency reference after moving `currency.iso_code` to `price_currency`.

### Added scope for currency show ads

As mentioned before, I added currency controller for the currency list and the link to currency with ads. To still link the ads to the currency table, I added a scope to ads model (app/models/ad.rb):
```
def self.currency_ads(currency_code)
  where(price_currency: currency_code)
end
```
In the show controller of currencies:
```
def show
  currency = Currency.find(params[:id])
  @ads = Ad.all.currency_ads(currency.iso_code)
end
```

The list of currencies is in `/currencies`.
![image](https://user-images.githubusercontent.com/25243082/77213567-3a680600-6b46-11ea-8aaf-2877642474ab.png)

Show view should be able to show the ads with that currency `/currency/1`:
![image](https://user-images.githubusercontent.com/25243082/77213598-58ce0180-6b46-11ea-9571-af89fd54e30f.png)
![image](https://user-images.githubusercontent.com/25243082/77213618-65525a00-6b46-11ea-95c3-5586d5ad375a.png)

I think the free plan of CurrencyLayer should work alright with this one since it will only have 1-3 requests each day to the API (`update_rates`). Maybe see how many is added to the API usage once you deploy it and check it each day and see if it will exceed 250 requests each month.


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
