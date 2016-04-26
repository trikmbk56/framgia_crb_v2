source "https://rubygems.org"

if Gem::Version.new(Bundler::VERSION) < Gem::Version.new("1.5.0")
  abort "Framgia CRB requires Bundler 1.5.0 or higher
    (you\"re using #{Bundler::VERSION}).\nPlease update
    with \"gem update bundler\"."
end

gem "rails", "4.2.6"
gem "mysql2"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.1.0"
gem "jquery-rails"
gem "turbolinks"
gem "jbuilder", "~> 2.0"
gem "sdoc", "~> 0.4.0", group: :doc
gem "parser", "~> 2.2.3"
gem "config"
gem "devise"
gem "cancancan"
gem "kaminari"
gem "jquery-ui-rails"
gem "i18n-js", ">= 3.0.0.rc11"
gem "select2-rails"
gem "paperclip", "~> 5.0.0.beta1"

group :development, :test do
  gem "pry"
  gem "web-console", "~> 2.0"
  gem "spring"
  gem "faker"
  gem "factory_girl_rails"
  gem "rspec-rails"
  gem "fabrication"
end
