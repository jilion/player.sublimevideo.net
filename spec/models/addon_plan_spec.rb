require 'fast_spec_helper'
require 'support/private_api_helpers'

require 'addon_plan'

describe AddonPlan do
  let(:site_token) { 'site_token' }
  let(:addon_plan1_hash) do
    {
      'addon' => {
        'name' => 'Logo'
      },
      'name' => 'sublime',
      'title' => 'SublimeVideo logo',
      'price' => 990,
      'required_stage' => 'stable'
    }
  end
  let(:addon_plan2_hash) do
    {
      'addon' => {
        'name' => 'Logo'
      },
      'name' => 'disabled',
      'title' => 'No SublimeVideo logo',
      'price' => 1990,
      'required_stage' => 'stable'
    }
  end
  let(:addon_plan1) { described_class.new(addon_plan1_hash) }
  let(:addon_plan2) { described_class.new(addon_plan2_hash) }

  describe '.all' do
    before do
      stub_api_for(described_class) do |stub|
        stub.get("/private_api/sites/#{site_token}/addons") { |env| [200, {}, [addon_plan1_hash, addon_plan2_hash].to_json] }
      end
    end

    it 'returns an array of addons' do
      described_class.all(site_token: site_token).should eq [addon_plan1, addon_plan2]
    end
  end
end
