require 'carrierwave/processing/mime_types'

class PackageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  process :set_content_type

  def fog_directory
    ENV['S3_PACKAGES_BUCKET']
  end

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if Rails.env.test?
      'uploads/packages'
    else
      'packages'
    end
  end

end