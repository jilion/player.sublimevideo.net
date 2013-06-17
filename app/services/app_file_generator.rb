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
      app_md5 = new(site, stage).generate_and_get_md5
      LoaderFileGeneratorWorker.perform_async(site_token, stage: stage, app_md5: app_md5)
    end
  end

  def generate_and_get_md5
    unless AppMd5.where(md5: _md5).exists?
      cdn_file.upload
      _increment_librato('update')
    end

    _md5
  end

  def cdn_file
    @cdn_file ||= CDNFile.new(_generate_file, _path, _s3_headers)
  end

  private

  def _generate_file
    template_path = Rails.root.join('app', 'templates', 'app.js.erb')
    template = ERB.new(File.new(template_path).read)
    file = Tempfile.new("a-#{site.token}.js", Rails.root.join('tmp'))
    file.print template.result(binding)
    file.rewind
    file
  end

  def _content
    @_content ||= _packages.reduce('') { |memo, package| memo += package.file.read }
  end

  def _path
    "s3/#{_md5}.js"
  end

  def _s3_headers
    {
      'Cache-Control' => 's-maxage=300, max-age=120, public', # 5 minutes / 2 minutes
      'Content-Type'  => 'text/javascript',
      'x-amz-acl'     => 'public-read'
    }
  end

  def _dependencies
    @_dependencies ||= PackagesDependenciesSolver.dependencies(site.packages(stage), stage)
  end

  def _packages
    @_packages ||= _dependencies.map { |name, version| Package.find_by_name_and_version(name, version) }
  end

  def _md5
    @_md5 ||= Digest::MD5.digest(_dependencies.sort.to_s)
  end

  def _increment_librato(action)
    Librato.increment "player.app.#{action}", source: stage
  end

end
