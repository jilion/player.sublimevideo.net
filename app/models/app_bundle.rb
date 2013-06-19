require 'mime/types'

class AppBundle < ActiveRecord::Base

  has_and_belongs_to_many :packages, join_table: 'app_bundles_packages'
  has_many :loaders

  validates :token, presence: true, uniqueness: true

  before_create :_upload_assets
  before_destroy :_remove_assets

  private

  def _path
    Pathname.new("a/#{token}/")
  end

  # When created, all its packages' assets file should be uploaded to S3 under /a/<token>/
  def _upload_assets
    packages.each do |package|
      package.assets { |assets| assets.each { |asset| _upload_asset(asset) } }
    end
  end

  def _remove_assets
    S3Wrapper.all(prefix: _path.to_s).files.each { |file| file.destroy }
  end

  def _upload_asset(asset)
    S3Wrapper.put(_path.join(asset[:name]).to_s, asset[:file].read, _s3_headers(asset[:file]))
  end

  def _s3_headers(file)
    {
      'Cache-Control' => 'max-age=29030400, public', # 5 minutes / 2 minutes
      'Content-Type'  => MIME::Types.type_for(file.path).first.to_s,
      'x-amz-acl'     => 'public-read'
    }
  end

end

# == Schema Information
#
# Table name: app_bundles
#
#  created_at :datetime
#  id         :integer          not null, primary key
#  token      :string(255)
#  updated_at :datetime
#
# Indexes
#
#  index_app_bundles_on_token  (token)
#

