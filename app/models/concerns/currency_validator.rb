class CurrencyValidator < ActiveModel::Validator
  def validate(record)
    unless record.price_currency == record.delivery_currency
      record.errors.add(:delivery, "cannot be a different currency from price_currency")
    end
  end
end