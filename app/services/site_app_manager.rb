require 'stage'
require 'app_manager'
require 'site_loader_manager_worker'

class SiteAppManager

  attr_reader :site, :stage

  def initialize(site, stage)
    @site, @stage = site, stage
  end

  def self.update(site_token)
    site = Site.find(site_token)

    Stage.stages_equal_or_more_stable_than(site.accessible_stage).each do |stage|
      update_for_stage_and_delay_loader_update(site, stage)
    end
  end

  def self.update_for_stage_and_delay_loader_update(site, stage)
    if app = new(site, stage).find_or_create
      SiteLoaderManagerWorker.perform_async(site.token, app.token, stage)
    end
  end

  # Returns the app_token generated from the `_original_packages` array.
  #
  def app_token
    @app_token ||= Digest::MD5.hexdigest(_original_packages.map(&:title).sort.to_s)
  end

  # Returns the app that correspond to the `app_token`.
  #
  def app
    @app ||= App.find_by_token(app_token)
  end

  # Retrieve an app record that corresponds to the `app_token` and if it
  # doesn't exist, create a new app record for the `_original_packages` and
  # `stage` with the token equal to `app_token`.
  #
  # @return the retrieved or newly created app record
  #
  def find_or_create
    AppManager.new(app_token, _original_packages, stage).create unless app

    app
  end

  private

  def _original_packages
    @_original_packages ||= site.packages(stage)
  end

end
