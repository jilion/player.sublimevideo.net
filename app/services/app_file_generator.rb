require 'cdn_file'
require 'packages_dependencies_solver'

class AppFileGenerator

  attr_reader :site, :stage

  def initialize(site, stage)
    @site, @stage = site, stage
  end

  def generate_and_upload
    cdn_file.upload
    _increment_librato('update')
  end

  def cdn_file
    @cdn_file ||= CDNFile.new(_generate_file, _path, _s3_headers)
  end

  def packages
    _dependencies.map { |name, version| Package.find_by_name_and_version(name, version) }
  end

  private

  def _generate_file
    file = Tempfile.new("a-#{site.token}.js", Rails.root.join('tmp'))
    packages.each do |package|
      file.write(package.file.read)
    end
    file.rewind
    file
  end

  def _path
    "s3/#{site.token}.js"
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

  def _increment_librato(action)
    Librato.increment "player.#{action}", source: 'app'
  end

end
