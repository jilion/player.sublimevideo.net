require 'vcr'

VCR.configure do |config|
  config.hook_into :webmock, :typhoeus
  config.cassette_library_dir     = 'spec/fixtures/vcr_cassettes'
  # config.ignore_hosts             'sublimevideo.dev', 'example.com'
  config.ignore_localhost         = true
  config.default_cassette_options = { record: :new_episodes }
  config.configure_rspec_metadata!
end
