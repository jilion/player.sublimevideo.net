require 'sublime_video_private_api'

class Site
  include SublimeVideoPrivateApi::Model

  uses_private_api :my

  belongs_to :default_kit, class_name: 'Kit'

  def addons
    @addons ||= Addon.all(site_token: token)
  end

  def kits
    @kits ||= Kit.all(site_token: token)
  end

  def packages(stage = 'stable')
    Package.packages_from_addons(addons, stage)
  end

end
