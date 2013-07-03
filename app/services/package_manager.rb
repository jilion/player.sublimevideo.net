class PackageManager

  attr_reader :package

  def initialize(package)
    @package = package
  end

  def create
    package.save!

    _update_app_and_settings_for_dependent_sites
    CampfireWrapper.delay.post("#{_campfire_message} released")

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def _update_app_and_settings_for_dependent_sites
    Loader.where(app_id: App.with_package_name(package.name).pluck(:app_id)).find_each do |loader|
      SiteAppManager.delay(queue: 'player').update(loader.site_token)
      SiteSettingsManager.delay(queue: 'player').update(loader.site_token)
    end
  end

  def _campfire_message
    "#{package.name.humanize} player package #{package.version}"
  end

end
