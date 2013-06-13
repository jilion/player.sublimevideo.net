class Package < ActiveRecord::Base

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

  # Returns all the package that corresponds to the given `addons` for the
  # given `design_name` and `stage`.
  #
  # @param [String] design_name the design name
  # @param [Array<Addon>] addons an array of addons
  # @param [String] addons a valid stage (alpha, beta, stable), defaults to
  #   stable
  #
  def self.packages_from_addons(design_name, addons, stage = 'stable')
    addons.reduce([]) do |memo, addon|
      memo += _packages_for_addon(design_name, addon.name, stage)
    end
  end

  # FIXME
  def self.app_packages(stage = 'stable')
    packages_for_design_and_name_and_stage(nil, 'app', stage)
  end

  def stage
    Stage.version_stage(version)
  end

  # @private
  def self._cached_packages(name)
    Rails.cache.fetch ['packages', name] { self.by_name(name).to_a }
  end

  # @private
  def self._packages_for_name_and_stage(name, stage)
    _cached_packages(name).select { |p| Stage.stages_equal_or_more_stable_than(stage).include?(p.stage) }
  end

  # @private
  def self._packages_for_addon(design_name, addon_name, stage)
    _packages_for_name_and_stage(DesignAddonToPackage.package(design_name, addon_name), stage)
  end

  # @private
  def _clear_caches
    Rails.cache.clear [self, 'find_cached_by_name', name]
  end

end
