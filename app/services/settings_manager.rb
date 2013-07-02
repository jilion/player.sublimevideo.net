require 'settings_file_manager'

# This class is responsible for delegating the settings for a given site.
#
class SettingsManager

  attr_reader :site, :stage

  def initialize(site, stage = 'stable')
    @site, @stage = site, stage
  end

  def update
    SettingsFileManager.new(site, stage).upload
    _increment_librato('update.succeed')

    true
  end

  def delete
    SettingsFileManager.new(site, stage).delete
    _increment_librato('delete.succeed')
  end

  private

  def _increment_librato(action)
    Librato.increment "player.settings.#{action}", source: stage
  end

end
