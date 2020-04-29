# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(first_name: "John", last_name: "Doe", email: "admin@admin.com", password: "password", password_confirmation: "password", username: "thisisjohndoe")
Currency.create(name: "United States Dollar", country: "United States", iso_code: "USD", website: "www.usd-currency.com")
Currency.create(name: "Philippines Peso", country: "Philippines", iso_code: "PHP", website: "www.php-currency.com")
Currency.create(name: "Japanese Yen", country: "Japan", iso_code: "JPY", website: "www.japan-currency.com")
Currency.create(name: "Euro", country: "Italy", iso_code: "EUR", website: "www.euro-currency.com")
