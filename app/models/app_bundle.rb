class AppBundle < ActiveRecord::Base

  has_and_belongs_to_many :packages, join_table: 'app_bundles_packages'
  has_many :loaders

  validates :token, presence: true
  validates :token, uniqueness: true

  # When created, all its packages' assets file should be uploaded to S3 under /<token>/

  # before :store, :store_zip_content
  # before :remove, :remove_zip_content

  # def store_zip_content(new_file)
  #   # new_file not used because nil
  #   zip_content_uploader.store_zip_content(file.path)
  # end

  # def remove_zip_content
  #   zip_content_uploader.remove_zip_content
  # end

  # def zip_content_uploader
  #   upload_path = Pathname.new("c/#{model.token}/#{model.version}/")
  #   PackageZipContentUploader.new(upload_path)
  # end

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

