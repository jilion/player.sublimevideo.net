require 'templated_file'

class AppFiles
  include TemplatedFile

  attr_reader :app_token, :packages, :stage

  def initialize(app_token, packages = [], stage = 'stable')
    @app_token, @packages, @stage = app_token, packages, stage
  end

  def root_path
    Pathname.new("ab/#{app_token}/")
  end

  def main_file_path
    root_path.join('app.js').to_s
  end

  def main_file_url
    "https://#{S3Wrapper.buckets[:sublimevideo]}.s3.amazonaws.com/#{main_file_path}"
  end

  def main_file_content
    _tempfile.print _template('app.js.erb').result(binding)
    _tempfile.rewind
    _tempfile
  end

  private

  # Binded in the template.
  #
  def _binded_content
    @_binded_content ||= _resolved_packages.reduce('') do |memo, package|
      memo += package.main_file { |f| f.read }
    end
  end

  def _resolved_packages
    @_resolved_packages ||= begin
      dependencies = PackagesDependenciesSolver.dependencies(packages, stage)
      dependencies.map { |name, version| Package.find_by_name_and_version(name, version) }
    end
  end

end
