require 'spec_helper'

describe Loader do

  describe 'Associations' do
    it { should belong_to(:app_bundle) }
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

