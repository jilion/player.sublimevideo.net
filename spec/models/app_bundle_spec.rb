require 'spec_helper'

describe AppBundle do

  describe 'Associations' do
    it { should have_and_belong_to_many(:packages) }
    it { should have_many(:loaders) }
  end

  describe "Validations" do
    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:token) }
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

