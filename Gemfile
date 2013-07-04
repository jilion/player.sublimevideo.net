source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg@gem.fury.io/me/' # thibaud@jilion.com account

ruby '2.0.0'

# Core frameworks, models, controllers & views
gem 'rails', '~> 4.0.0'
gem 'serialize-rails'
gem 'sublime_video_private_api', '~> 1.5'

gem 'responders',          github: 'plataformatec/responders'
gem 'inherited_resources', github: 'josevalim/inherited_resources'
gem 'ransack',             github: 'ernie/ransack', branch: 'rails-4'
gem 'activeadmin',         github: 'gregbell/active_admin', branch: 'rails4'
gem 'formtastic',          github: 'justinfrench/formtastic'

gem 'slim'

# Databases & queues
gem 'pg'
gem 'sidekiq'

# Assets management
gem 'fog'
gem 'carrierwave'
gem 'rubyzip', require: 'zip/zip'
gem 'mime-types'

# Packages dependencies solving
gem 'solve'

# Third-party services integration
gem 'tinder' # Campfire
gem 'librato-rails', github: 'librato/librato-rails', branch: 'feature/rack_first'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier', '>= 1.0.3'

group :staging, :production do
  gem 'unicorn'
  gem 'rack-devise_cookie_auth'
end

group :development, :test do
  gem 'dotenv-rails'
end

group :development do
  gem 'ruby_gntp', require: false
  gem 'guard-rspec', require: false

  gem 'annotate'
  gem 'silent-postgres'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails' # loaded in spec_helper Spork.each_run
  gem 'database_cleaner'
  gem 'webmock'
  gem 'typhoeus'
  gem 'vcr'
end
