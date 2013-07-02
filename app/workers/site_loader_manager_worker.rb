require 'sidekiq'
require 'site_loader_manager'

class SiteLoaderManagerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  def perform(site_token, app_token, stage)
    SiteLoaderManager.update(site_token, app_token, stage)
  end
end
