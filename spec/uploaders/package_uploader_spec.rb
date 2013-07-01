require 'fast_spec_helper'
require 'rails/railtie'
require 'carrierwave'
require 'fog'
require 'config/carrierwave' # for fog_mock
require 'support/zip_helpers'

require 'uploaders/package_uploader'

describe PackageUploader, :fog_mock, :zip do
  let(:package)  { stub(name: 'classic-player-controls', version: '1.0.0') }
  let(:package_name) { "#{package.name}-#{package.version}" }
  let(:zip_name) { "#{package_name}.zip" }
  let(:zip) { fixture_file(File.join('packages', zip_name)) }
  let(:uploader) { described_class.new(package, :zip) }

  before { uploader.store!(zip) }

  it 'saves the file in the right bucket' do
    uploader.fog_directory.should eq S3Wrapper.buckets[:player]
  end

  it 'is private' do
    uploader.fog_public.should be_false
  end

  it 'has a secure url with S3 bucket path' do
    uploader.url.should =~ %r{\Ahttps://#{uploader.fog_directory}\.s3\.amazonaws\.com/#{uploader.store_dir}/#{Regexp.escape(zip_name)}\?AWSAccessKeyId=#{ENV['S3_ACCESS_KEY_ID']}&Signature=foo&Expires=\d+\Z}
  end

  it 'has zip content_type' do
    uploader.file.content_type.should eq 'application/zip'
  end

  it 'has zip extension' do
    uploader.file.path.should match /\.zip$/
  end

  it 'has good filename' do
    uploader.filename.should eq zip_name
  end

end
