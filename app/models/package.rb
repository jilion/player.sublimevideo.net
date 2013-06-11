class Package < ActiveRecord::Base

  has_and_belongs_to_many :app_md5s, join_table: 'app_md5s_packages'

  serialize :dependencies, JSON

  mount_uploader :zip, PackageUploader

end
