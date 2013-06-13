require 'fast_spec_helper'
require 'support/private_api_helpers'

require 'addon'

describe Addon do
  let(:site_token) { 'site_token' }
  let(:addon_plan1) do
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
  let(:addon_plan2) do
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

  describe '.all' do
    before do
      stub_api_for(Addon) do |stub|
        stub.get("/private_api/sites/#{site_token}/addons") { |env| [200, {}, [addon_plan1, addon_plan2].to_json] }
      end
    end

    it 'returns an array of addons' do
      described_class.all(site_token: site_token).should eq [Addon.new(addon_plan1), Addon.new(addon_plan2)]
    end
  end
end
