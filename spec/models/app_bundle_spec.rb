require 'spec_helper'

describe AppBundle do
  let(:app_bundle) { create(:app_bundle) }
  let(:app_bundle_with_packages) { create(:app_bundle, packages: [create(:classic_player_controls_1_0_0), create(:sony_player_1_0_0)]) }

  context 'Factory' do
    subject { app_bundle }

    its(:token)    { should be_present }
    it { should be_valid }
  end

  describe 'Associations' do
    it { should have_and_belong_to_many(:packages) }
    it { should have_many(:loaders) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:token) }
  end

  describe 'before_create' do
    it 'upload all packages assets files to S3' do
      S3Wrapper.all(prefix: app_bundle_with_packages.send(:_path)).files.should have(2).files
    end
  end

  describe 'before_destroy' do
    it 'removes all assets for this bundle from S3' do
      S3Wrapper.all(prefix: app_bundle_with_packages.send(:_path)).files.should have(2).files
      app_bundle_with_packages.destroy
      S3Wrapper.all(prefix: app_bundle_with_packages.send(:_path)).files.should have(0).files
    end
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

