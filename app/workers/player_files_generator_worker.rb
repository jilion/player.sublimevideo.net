require 'sidekiq'
require 'site_settings_manager'
require 'site_app_manager'
require 'site_loader_manager'
require 'site_settings_manager'

class PlayerFilesGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  # @param [Symbol] event defines the event that triggered the `perform`
  #   events can be:
  #   * `:settings_update` => the site has been saved or its kits settings have been saved
  #   * `:addons_update`   => the site's addons have been updated
  #   * `:cancellation`    => the site has been archived
  #
  def perform(site_token, event)
    case event
    when :settings_update
      SiteSettingsManager.update(site_token)
    when :addons_update
      SiteAppManager.update(site_token)
    when :cancellation
      SiteLoaderManager.delete(site_token)
      SiteSettingsManager.delete(site_token)
    end
  end
end
