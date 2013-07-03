source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg@gem.fury.io/me/' # thibaud@jilion.com account

ruby '2.0.0'

# Core frameworks
gem 'rails', '~> 4.0.0'
gem 'serialize-rails'
gem 'sublime_video_private_api', '~> 1.5'

# Views
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

# Gems used only for assets and not required
# in production environments by default.
# group :assets do
#   gem 'sass-rails',   '~> 3.2.3'
#   gem 'coffee-rails', '~> 3.2.1'
#
#   # See https://github.com/sstephenson/execjs#readme for more supported runtimes
#   # gem 'therubyracer', :platforms => :ruby
#
#   gem 'uglifier', '>= 1.0.3'
# end
#
# gem 'jquery-rails'

group :staging, :production do
  gem 'unicorn'
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
