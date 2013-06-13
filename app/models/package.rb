class Package < ActiveRecord::Base

  ADDON_TO_PACKAGE = {
    app: 'app',
    video_player: 'video_player',
    controls: 'controls',
    initial: 'initial',
    lightbox: 'lightbox',
    image_viewer: 'image_viewer',
    stats: 'stats',
    google_analytics: 'google_analytics',
    logo: 'logo',
    cuezones: 'cuezones',
    sharing: 'sharing',
    social_sharing: 'social_sharing',
    embed: 'embed',
    api: 'api',
    support: 'support',
    preview_tools: 'preview_tools',
    buy_action: 'buy_action',
    action: 'action',
    info: 'info',
    end_actions: 'end_actions',
    dmt_controls: 'dmt_controls',
    dmt_quality: 'dmt_quality',
    dmt_logo: 'dmt_logo',
    dmt_sharing: 'dmt_sharing',
    psg_controls: 'psg_controls',
    psg_logo: 'psg_logo',
    rng_controls: 'rng_controls'
  }

  has_and_belongs_to_many :app_md5s

  serialize :dependencies, Hash, format: :json

  mount_uploader :zip, PackageUploader

  validates :name, :version, presence: true

  before_save ->(package) do
    package.dependencies ||= {}
  end

  after_touch :_clear_caches
  after_save :_clear_caches

  scope :by_name, ->(name) { where(name: name.to_s) }
  default_scope -> { order('created_at DESC') }

  def self.packages_from_addons(addons, stage = 'stable')
    addons.reduce([]) do |memo, addon|
      memo += _packages_for_addon(addon, stage)
    end
  end

  def self.packages_for_name(name, stage)
    _cached_packages(name).select { |p| Stage.stages_equal_or_more_stable_than(stage).include?(p.stage) }
  end

  def self.app_packages(stage = 'stable')
    packages_for_name('app', stage)
  end

  def stage
    Stage.version_stage(version)
  end

  # @private
  def self._packages_for_addon(addon, stage)
    packages_for_name(_package_name_from_addon_name(addon.name), stage)
  end

  # @private
  def self._package_name_from_addon_name(addon_name)
    ADDON_TO_PACKAGE[addon_name.to_sym]
  end

  # @private
  def self._cached_packages(name)
    Rails.cache.fetch ['packages', name] { self.by_name(name).to_a }
  end

  # @private
  def _clear_caches
    Rails.cache.clear [self, 'find_cached_by_name', name]
  end

end
