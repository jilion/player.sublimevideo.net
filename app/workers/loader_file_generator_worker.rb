require 'sidekiq'
require 'loader_file_generator'

class LoaderFileGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  def perform(site_token)
    LoaderFileGenerator.new(site_token).generate_and_upload
  end
end
