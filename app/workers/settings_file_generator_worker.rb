require 'sidekiq'
require 'settings_file_generator'

class SettingsFileGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  def perform(site_token)
    SettingsFileGenerator.new(Site.find(site_token)).generate_and_upload
  end
end
