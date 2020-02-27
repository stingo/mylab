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
