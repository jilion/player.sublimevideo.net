require 'fast_spec_helper'
require 'support/private_api_helpers'

require 'kit'

describe Kit do
  let(:site_token) { 'site_token' }
  let(:kit) do
    {
      'design' => {
        'name' => 'Classic'
      },
      'identifier' => 'foo',
      'name' => 'Foo player',
      'settings' => {}
    }
  end

  describe '.all' do
    before do
      stub_api_for(Kit) do |stub|
        stub.get("/private_api/sites/#{site_token}/kits") { |env| [200, {}, [kit].to_json] }
      end
    end

    it 'returns an array of kits' do
      described_class.all(site_token: site_token).should eq [Kit.new(kit)]
    end
  end
end
