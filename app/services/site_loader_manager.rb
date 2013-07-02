require 'stage'
require 'loader_manager'

# This class delegates the loader generation for all the accessible stages of
# a given site.
#
class SiteLoaderManager

  attr_reader :site, :app, :stage

  def initialize(site, app, stage)
    @site, @app, @stage = site, app, stage
  end

  class << self

    # @example
    #   SiteLoaderManager.update('abcd1234', 'foobar', 'beta')
    #
    #   SiteLoaderManager.delete('abcd1234')
    #
    %w[update delete].each do |action|
      define_method(action) do |site_token, app_token = nil, stage = nil|
        site = Site.find(site_token)
        app = App.find_by_token(app_token)

        Array(stage || Stage.stages_equal_or_more_stable_than(site.accessible_stage)).each do |stage|
          LoaderManager.new(site_token, app, stage).send(action)
        end
      end
    end

  end

end
