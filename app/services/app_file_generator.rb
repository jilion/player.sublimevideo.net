require 'stage'
require 'cdn_file'
require 'packages_dependencies_solver'
require 'loader_file_generator_worker'

class AppFileGenerator

  attr_reader :site, :stage

  def initialize(site, stage)
    @site, @stage = site, stage
  end

  def self.update(site_token)
    Stage.stages.each do |stage|
      update_for_stage(site_token, stage)
    end
  end

  def self.update_for_stage(site_token, stage)
    site = Site.find(site_token)

    if Stage.stages_equal_or_more_stable_than(site.accessible_stage).include?(stage)
      bundle_token = new(site, stage).generate_and_get_bundle_token
      LoaderFileGeneratorWorker.perform_async(site_token, stage: stage, bundle_token: bundle_token)
    end
  end

  def bundle_token
    @bundle_token ||= Digest::MD5.hexdigest(_original_packages.sort.to_s)
  end

  def cdn_file
    @cdn_file ||= CDNFile.new(_generate_file, _path, _s3_headers)
  end

  def generate_and_get_bundle_token
    unless _app_bundle
      AppBundle.create!(token: bundle_token, packages: _original_packages)
      cdn_file.upload
      _increment_librato('update')
    end
    _create_loader

    bundle_token
  end

  private

  def _app_bundle
    @_app_bundle ||= AppBundle.find_by_token(bundle_token)
  end

  def _generate_file
    template_path = Rails.root.join('app', 'templates', 'app.js.erb')
    template = ERB.new(File.new(template_path).read)
    file = Tempfile.new("a-#{site.token}.js", Rails.root.join('tmp'))
    file.print template.result(binding)
    file.rewind
    file
  end

  def _binded_content
    @_binded_content ||= _resolved_packages.reduce('') do |memo, package|
      memo += package.main_file { |f| f.read }
    end
  end

  def _path
    "app/#{bundle_token}.js"
  end

  def _s3_headers
    {
      'Cache-Control' => 's-maxage=300, max-age=120, public', # 5 minutes / 2 minutes
      'Content-Type'  => 'text/javascript',
      'x-amz-acl'     => 'public-read'
    }
  end

  def _original_packages
    @_original_packages ||= site.packages(stage)
  end

  def _resolved_packages
    @_resolved_packages ||= begin
      dependencies = PackagesDependenciesSolver.dependencies(_original_packages, stage)
      dependencies.map { |name, version| Package.find_by_name_and_version(name, version) }
    end
  end

  def _create_loader
    Loader.create(app_bundle: _app_bundle, site_token: site.token)
  end

  def _increment_librato(action)
    Librato.increment "player.app.#{action}", source: stage
  end

end
