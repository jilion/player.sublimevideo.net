require 'sidekiq'
require 'app_file_generator'

class AppFileGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  def perform(site_token)
    AppFileGenerator.update(site_token)
  end
end
