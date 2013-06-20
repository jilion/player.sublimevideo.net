require 'stage'
require 'app_manager'
require 'site_loader_manager_worker'

class SiteAppManager

  attr_reader :site, :stage

  def initialize(site, stage)
    @site, @stage = site, stage
  end

  def self.update(site_token)
    Stage.stages.each do |stage|
      update_for_stage(site_token, stage)
    end
  end

  def self.update_for_stage(site_token, stage)
    site = Site.find(site_token)

    return unless Stage.stages_equal_or_more_stable_than(site.accessible_stage).include?(stage)

    if app = new(site, stage).find_or_create
      SiteLoaderManagerWorker.perform_async(site_token, app.token, stage)
    end
  end

  def app_token
    @app_token ||= Digest::MD5.hexdigest(_original_packages.map(&:title).sort.to_s)
  end

  def app
    @app ||= App.find_by_token(app_token)
  end

  def find_or_create
    AppManager.new(app_token, _original_packages, stage).create unless app

    app
  end

  private

  def _original_packages
    @_original_packages ||= site.packages(stage)
  end

end
