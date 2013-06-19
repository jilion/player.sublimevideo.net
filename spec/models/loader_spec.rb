require 'spec_helper'

describe Loader do
  context 'Factory' do
    subject { create(:loader) }

    its(:site_token) { should be_present }
    its(:app_bundle) { should be_present }
    it { should be_valid }
  end

  describe 'Associations' do
    it { should belong_to(:app_bundle) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:site_token) }
    it { should validate_uniqueness_of(:site_token) }
  end

end

# == Schema Information
#
# Table name: loaders
#
#  app_bundle_id :integer
#  created_at    :datetime
#  id            :integer          not null, primary key
#  site_token    :string(255)
#  updated_at    :datetime
#
# Indexes
#
#  index_loaders_on_app_bundle_id  (app_bundle_id)
#

