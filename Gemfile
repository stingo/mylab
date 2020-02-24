source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.0"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 3.12"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 4.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem "devise", "~> 4.2"
gem "simple_form", ">= 5.0.0"
# gem 'simple_form', '~> 3.5'
gem "countries", require: "countries/global"
gem "country_select", "~> 4.0"
gem "flag-icons-rails"
gem "impressionist", git: "https://github.com/charlotte-ruby/impressionist"
# gem 'font-awesome-rails' # Font-awesome icon
gem "carrierwave", "~> 2.0"
gem "devise-bootstrapped", github: "excid3/devise-bootstrapped", branch: "bootstrap4"
gem "font-awesome-sass", "~> 5.11.2"
gem "friendly_id", "~> 5.2", ">= 5.2.5"
gem "gravatar_image_tag", github: "mdeering/gravatar_image_tag"
gem "jquery-rails"
gem "mini_magick", "~> 4.9", ">= 4.9.2"

gem "bootsnap", ">= 1.4.2", require: false

group :development, :test do
  gem "annotate"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "pry-rails"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "webdrivers"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
