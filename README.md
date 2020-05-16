# Delivery Fee

## Migration for delivery fee

Create a migration for adding a monetized delivery column on ad table.

```
class AddDeliveryOnAds < ActiveRecord::Migration[6.0]
  def change
    add_monetize :products, :delivery
  end
end
```

## Monetize delivery

Make sure to add monetize delivery to Ad model and delivery_fee money method.

```
class Ad < ApplicationRecord
  ...
  monetize :delivery_cents
  ...

  def delivery
    Money.new delivery_cents, delivery_currency
  end
end

```

## Ad form

Add input delivery with Money.delivery_fee (method from above ^^)

```
<div class="form-inputs">
  <%= f.input :title %>
  <%= f.input :description %>
  <%= f.input :price, as: :numeric, input_html: { step: 0.5 } %>
  <%= f.select :price_currency, [["USD- US Dollars", "USD"],
                                 ["JPY- Japanese Yen", "JPY"],
                                 ["PHP - Philippine Peso", "PHP"],
                                 ["EUR - European Pound", "EUR"]],
               selected: session[:currency] %>

  // add this line to your ad form
  <%= f.input :delivery, as: :numeric, input_html: { step: 0.5 } %>
</div>
```

## Ad Controller

Whitelist delivery in the params

```
 # Never trust parameters from the scary internet, only allow the white list through.
  def ad_params
    params.require(:ad).permit(:title, :description, :price, :price_currency, :delivery, :slug)
  end
```

Add these to the ad create

```
def create
    @ad = current_user.ads.build(ad_params)
    @ad.delivery_currency = ad_params["price_currency"]

    respond_to do |format|
      if @ad.save
        format.html { redirect_to @ad, notice: "Ad was successfully created." }
        format.json { render :show, status: :created, location: @ad }
      else
        format.html { render :new }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end
```

## Ad Model: Convert to cents

Convert the price and delivery param value to cents

```
  before_create :convert_cents_to_money

  private

  def convert_cents_to_money
    Ad.update(
      price_cents: price_cents.to_money.cents,
      delivery_cents: delivery_cents.to_money.cents
    )
  end
```

## Custom validation

Add custom model validation to make sure delivery_currency and price_currency are the same value

Add below to the ad model:

```
  validates_with CurrencyValidator
```

On `app/models/concerns`, add a file (currency_validation.rb).

```
class CurrencyValidator < ActiveModel::Validator
  def validate(record)
    unless record.price_currency == record.delivery_currency
      record.errors.add(:delivery, "cannot be a different currency from price_currency")
    end
  end
end
```
