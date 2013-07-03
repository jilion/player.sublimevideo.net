class App < ActiveRecord::Base

  has_and_belongs_to_many :packages, join_table: 'apps_packages'
  has_many :loaders

  validates :token, presence: true, uniqueness: true

  scope :with_package_name, ->(package_name) { includes(:packages).where(packages: { name: package_name }) }

end

# == Schema Information
#
# Table name: apps
#
#  created_at :datetime
#  id         :integer          not null, primary key
#  token      :string(255)
#  updated_at :datetime
#
# Indexes
#
#  index_apps_on_token  (token)
#

