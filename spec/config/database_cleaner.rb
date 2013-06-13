RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
