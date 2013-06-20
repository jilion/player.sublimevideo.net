require 'sidekiq'
require 'site_app_manager'

class AppManagerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  def perform(site_token)
    SiteAppManager.update(site_token)
  end
end
