require 'sidekiq'
require 'app_file_generator'

class AppFileGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  def perform(site_token)
    AppFileGenerator.new(site_token).generate_and_upload
  end
end
