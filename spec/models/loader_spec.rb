require 'spec_helper'

describe Loader do
  context 'Factory' do
    subject { create(:loader) }

    its(:site_token) { should be_present }
    its(:app) { should be_present }
    it { should be_valid }
  end

  describe 'Associations' do
    it { should belong_to(:app) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:site_token) }
    it { should validate_uniqueness_of(:app_id).scoped_to([:site_token, :stage]) }
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

