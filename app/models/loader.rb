class Loader < ActiveRecord::Base

  belongs_to :app

  validates :app_id, :site_token, :stage, presence: true
  validates :app_id, uniqueness: { scope: [:site_token, :stage] }

  scope :stable,  -> { where(stage: 'stable') }
  scope :beta,    -> { where(stage: 'beta') }
  scope :alpha,   -> { where(stage: 'alpha') }
  default_scope   -> { order('updated_at DESC') }

  def file
    @file ||= LoaderFile.new(site_token, stage)
  end

end

# == Schema Information
#
# Table name: loaders
#
#  app_id     :integer
#  created_at :datetime
#  id         :integer          not null, primary key
#  site_token :string(255)
#  stage      :string(255)
#  updated_at :datetime
#
# Indexes
#
#  index_loaders_on_app_id                           (app_id)
#  index_loaders_on_app_id_and_site_token_and_stage  (app_id,site_token,stage) UNIQUE
#  index_loaders_on_site_token                       (site_token)
#  index_loaders_on_site_token_and_stage             (site_token,stage)
#

