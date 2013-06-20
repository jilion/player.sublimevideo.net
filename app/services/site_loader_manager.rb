require 'stage'

require 'loader_manager'

class SiteLoaderManager
  extend Forwardable

  attr_reader :site, :app, :stage, :options

  def initialize(site, app, stage, options = {})
    @site, @app, @stage, @options = site, app, stage, options
  end

  def self.update(site_token, app_token = nil, stage = nil, options = {})
    site = Site.find(site_token)
    app = App.find_by_token(app_token)

    Array(stage || Stage.stages).each do |stage|
      new(site, app, stage, options).update
    end
  end

  def update
    loader_manager = LoaderManager.new(site, app, stage)

    if options[:delete]
      loader_manager.delete
    else
      loader_manager.update
    end
  end

end
