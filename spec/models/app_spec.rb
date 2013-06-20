require 'spec_helper'

describe App do
  let(:app) { create(:app) }
  let(:app_with_packages) { create(:app, packages: [create(:classic_player_controls_1_0_0), create(:sony_player_1_0_0)]) }

  context 'Factory' do
    subject { app }

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

