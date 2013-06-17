require 'sidekiq'
require 'loader_file_generator'

class LoaderFileGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  def perform(site_token, options = {})
    LoaderFileGenerator.update(site_token, options)
  end
end
