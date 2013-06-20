require 'cdn_file'
require 'mime/types'
require 'packages_dependencies_solver'

class AppManager

  attr_reader :token, :packages, :stage

  def initialize(token, packages = [], stage = 'stable')
    @token, @packages, @stage = token, packages, stage
  end

  def create
    @app = App.create!(token: token, packages: packages)
    _upload_app_file
    _upload_app_assets
    _increment_librato('create.succeed')

    true

  rescue ActiveRecord::RecordInvalid
    _increment_librato('create.failed')
    false
  end

  def delete
    if app = App.find_by_token(token)
      app.destroy!

      _delete_app_files

      _increment_librato('delete.succeed')
    end
  end

  def app_file
    path = _path.join('app.js').to_s
    CDNFile.new(_app_file, path, _s3_headers(path))
  end

  private

  def _path
    Pathname.new("ab/#{token}/")
  end

  def _upload_app_file
    app_file.upload
  end

  def _upload_app_assets
    packages.each do |package|
      package.assets { |assets| assets.each { |asset| _upload_asset(package, asset) } }
    end
  end

  def _upload_asset(package, asset)
    CDNFile.new(
      asset[:file],
      _path.join("#{package.name}/#{asset[:name]}").to_s,
      _s3_headers(asset[:file].path)
    ).upload
  end

  def _delete_app_files
    S3Wrapper.all(S3Wrapper.buckets[:sublimevideo], prefix: _path.to_s).files.each { |file| file.destroy }
  end

  def _app_file
    template_path = Rails.root.join('app', 'templates', 'app.js.erb')
    template = ERB.new(File.new(template_path).read)
    file = Tempfile.new(["app-#{token}", '.js'], Rails.root.join('tmp'))
    file.print template.result(binding)
    file.rewind
    file
  end

  def _binded_content
    @_binded_content ||= _resolved_packages.reduce('') do |memo, package|
      memo += package.main_file { |f| f.read }
    end
  end

  def _s3_headers(filename)
    content_type = filename =~ /\.js\Z/ ? 'text/javascript' : MIME::Types.type_for(filename).first

    {
      'Cache-Control' => 'max-age=29030400, public', # 5 minutes / 2 minutes
      'Content-Type'  => content_type.to_s,
      'x-amz-acl'     => 'public-read'
    }
  end

  def _resolved_packages
    @_resolved_packages ||= begin
      dependencies = PackagesDependenciesSolver.dependencies(packages, stage)
      dependencies.map { |name, version| Package.find_by_name_and_version(name, version) }
    end
  end

  def _increment_librato(action)
    Librato.increment "player.app.#{action}", source: stage
  end

end
