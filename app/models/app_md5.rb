class AppMd5 < ActiveRecord::Base

  has_and_belongs_to_many :packages, join_table: 'app_md5s_packages'
  has_one :loader

end
