require 'sidekiq'
require 'settings_file_generator'

class SettingsFileGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  def perform(site_token, options = {})
    SettingsFileGenerator.update(site_token, options)
  end
end
