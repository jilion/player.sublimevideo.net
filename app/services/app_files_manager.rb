require 'packages_dependencies_solver'
require 'cdn_file'
require 'mime/types'

# This class is responsible for creating / uploading / removing an app files
# associated to an app and a stage.
#
class AppFilesManager

  attr_reader :app_token, :packages, :stage

  def initialize(app_token, packages, stage = 'stable')
    @app_token, @packages, @stage = app_token, packages, stage
  end

  def upload
    cdn_app_main_file.upload
    _upload_app_assets
  end

  def delete
    _delete_app_files
  end

  def cdn_app_main_file
    CDNFile.new(
      _app_files.main_file_content,
      _app_files.main_file_path,
      _s3_headers(_app_files.main_file_path)
    )
  end

  private

  def _app_files
    @_app_files ||= AppFiles.new(app_token, packages, stage)
  end

  def _upload_app_assets
    packages.each do |package|
      package.assets { |assets| assets.each { |asset| _upload_asset(package, asset) } }
    end
  end

  def _upload_asset(package, asset)
    CDNFile.new(
      asset[:file],
      _app_files.root_path.join("#{package.name}/#{asset[:name]}").to_s,
      _s3_headers(asset[:file].path)
    ).upload
  end

  def _delete_app_files
    S3Wrapper.all(S3Wrapper.buckets[:sublimevideo], prefix: _app_files.root_path.to_s).files.each { |file| file.destroy }
  end

  def _s3_headers(filename)
    content_type = filename =~ /\.js\Z/ ? 'text/javascript' : MIME::Types.type_for(filename).first

    {
      'Cache-Control' => 'max-age=29030400, public', # 5 minutes / 2 minutes
      'Content-Type'  => content_type.to_s,
      'x-amz-acl'     => 'public-read'
    }
  end

end
