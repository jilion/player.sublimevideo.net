require 'zip/zip'

class Package < ActiveRecord::Base

  has_and_belongs_to_many :app_bundles

  serialize :dependencies, Hash, format: :json
  serialize :settings, Hash, format: :json

  mount_uploader :zip, PackageUploader

  validates :name, :version, :zip, presence: true
  validates :version, uniqueness: { scope: :name }

  before_create :_set_dependencies
  before_create :_set_settings

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
    Array(addon_names).reduce([]) do |memo, addon_name|
      memo += _packages_for_addon(design_name, addon_name, stage)
    end
  end

  def self.packages_for_name_and_stage(name, stage)
    _cached_packages(name).select { |p| Stage.stages_equal_or_more_stable_than(stage).include?(p.stage) }
  end

  # FIXME, is this method needed?
  def self.app_packages(stage = 'stable')
    packages_from_addons(nil, 'app', stage)
  end

  def stage
    Stage.version_stage(version)
  end

  def main_file
    return unless zip?

    tmpfile = Tempfile.new(["main-#{name}-#{version}", '.js'])

    _zip_file do |z|
      tmpfile.write(z.read("#{File.basename(zip.path, '.zip')}/main.js"))
    end
    tmpfile.rewind

    yield tmpfile
  ensure
    tmpfile.close
    tmpfile.unlink
  end

  def assets
    return unless zip?

    assets = []
    Zip::ZipFile.foreach(zip.path) do |z|
      next unless z.name =~ %r{assets/(\w+)\.\w{2,3}}

      tmpfile = Tempfile.new(["asset-#{name}-#{version}-#{File.basename(z.name)}", File.extname(z.name)])
      z.get_input_stream { |io| tmpfile.print(io.read) }
      tmpfile.rewind

      assets << { name: File.basename(z.name), file: tmpfile }
    end

    yield assets
  ensure
    assets.each do |asset|
      asset[:file].close
      asset[:file].unlink
    end
  end

  # @private
  def self._cached_packages(name)
    Rails.cache.fetch ['packages', name] { self.by_name(name).to_a }
  end

  # @private
  def self._packages_for_addon(design_name, addon_name, stage)
    packages_for_name_and_stage(DesignAddonToPackage.package(design_name, addon_name), stage)
  end

  private

  def _zip_file
    return unless zip?

    Zip::ZipFile.open(zip.path) { |z| yield z }
  end

  def _dependencies_from_zip
    return {} unless zip?

    @_dependencies_from_zip ||= JSON[_zip_file { |z| z.read("#{File.basename(zip.path, '.zip')}/package.json") }]['dependencies']
  end

  def _settings_from_zip
    return {} unless zip?

    @_settings_from_zip ||= begin
      settings = {}
      Zip::ZipFile.foreach(zip.path) do |z|
        next unless z.name =~ %r{addons_settings/(\w+)\.json}

        settings.merge!($1 => JSON[z.get_input_stream { |io| io.read }])
      end

      settings
    end
  end

  def _set_dependencies
    self.dependencies = _dependencies_from_zip
  end

  def _set_settings
    self.settings = _settings_from_zip
  end

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
#  zip          :string(255)
#
# Indexes
#
#  index_packages_on_name              (name)
#  index_packages_on_name_and_version  (name,version) UNIQUE
#

