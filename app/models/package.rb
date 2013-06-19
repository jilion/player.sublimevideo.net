class Package < ActiveRecord::Base

  has_and_belongs_to_many :app_bundles

  serialize :dependencies, Hash, format: :json
  serialize :settings, Hash, format: :json

  mount_uploader :zip, PackageUploader

  validates :name, :version, presence: true
  validates :version, uniqueness: { scope: :name }

  before_save ->(package) do
    package.dependencies ||= {}
    package.settings ||= {}
  end

  after_touch :_clear_caches
  after_save :_clear_caches

  scope :by_name, ->(name) { where(name: name.to_s) }
  default_scope -> { order('created_at DESC') }

  # Returns all the package that corresponds to the given `addon_names` for the
  # given a `design_name` and a `stage`.
  #
  # @param [String] design_name the design name
  # @param [Array<Addon>] addon_names an array of addons names
  # @param [String] stage a valid stage (alpha, beta, stable), defaults to
  #   stable
  #
  def self.packages_from_addons(design_name, addon_names, stage = 'stable')
    addon_names.reduce([]) do |memo, addon_name|
      memo += _packages_for_addon(design_name, addon_name, stage)
    end
  end

  # FIXME, is this method needed?
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
    Rails.cache.clear ['packages', name]
  end

end

# == Schema Information
#
# Table name: packages
#
#  created_at   :datetime
#  dependencies :json
#  id           :integer          not null, primary key
#  name         :string(255)
#  settings     :json
#  updated_at   :datetime
#  version      :string(255)
#
# Indexes
#
#  index_packages_on_name              (name)
#  index_packages_on_name_and_version  (name,version) UNIQUE
#

