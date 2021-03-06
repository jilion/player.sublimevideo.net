require 'spec_helper'

describe Kit do
  let(:site_token) { 'site_token' }
  let(:kit) { described_class.new(kit_hash) }

  describe '.all' do
    before do
      stub_api_for(described_class) do |stub|
        stub.get("/private_api/sites/#{site_token}/kits") { |env| [200, {}, [kit_hash].to_json] }
      end
    end

    it 'returns an array of kits' do
      kits = described_class.all(site_token: site_token)

      kits[0].should eq kit
      kits[0].design['name'].should eq 'sony'
      kits[0].design['module'].should eq 'sony-player/sony'
    end
  end
end
