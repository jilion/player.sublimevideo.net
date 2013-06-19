require 'sublime_video_private_api'

class Site
  include SublimeVideoPrivateApi::Model

  uses_private_api :my

  belongs_to :default_kit, class_name: 'Kit'

  def addon_plans
    @addon_plans ||= AddonPlan.all(site_token: token)
  end

  def kits
    @kits ||= Kit.all(site_token: token)
  end

  def packages(stage = 'stable')
    design_names = kits.map { |kit| kit.design['name'] }.uniq
    addon_names = addon_plans.map { |addon_plan| addon_plan.addon['name'] }

    design_names.map { |design_name| Package.packages_from_addons(design_name, addon_names, stage) }.flatten.uniq
  end

end
