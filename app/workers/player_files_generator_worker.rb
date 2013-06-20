require 'sidekiq'
require 'app_manager_worker'
require 'site_loader_manager_worker'
require 'settings_file_generator_worker'

class PlayerFilesGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'player'

  # @param [Symbol] event defines the event that triggered the `perform`
  #   events can be:
  #   * `:settings` => the site has been saved or its kits settings have been saved
  #   * `:addons`   => the site's addons have been updated
  #   * `:destroy`  => the site has been archived
  #
  def perform(site_token, event)
    case event
    when :settings
      SettingsFileGeneratorWorker.perform_async(site_token)
    when :addons
      AppManagerWorker.perform_async(site_token)
    when :destroy
      SiteLoaderManagerWorker.perform_async(site_token, nil, nil, delete: true)
      SettingsFileGeneratorWorker.perform_async(site_token, delete: true)
    end
  end
end
