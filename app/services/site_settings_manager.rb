require 'stage'
require 'settings_manager'

class SiteSettingsManager

  attr_reader :site, :stage

  def initialize(site, stage)
    @site, @stage = site, stage
  end

  class << self

    # @example
    #   SiteSettingsManager.update('abcd1234', 'beta')
    #
    #   SiteSettingsManager.delete('abcd1234')
    #
    %w[update delete].each do |action|
      define_method(action) do |site_token, stage = nil|
        site = Site.find(site_token)

        Array(stage || Stage.stages_equal_or_more_stable_than(site.accessible_stage)).each do |stage|
          SettingsManager.new(site, stage).send(action)
        end
      end
    end

  end

end
