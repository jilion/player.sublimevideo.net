require 'spec_helper'

describe Site do
  let(:site) { Site.new(token: 'abcd1234') }

  describe '#addons' do
    it 'returns an array of kits' do
      Addon.should_receive(:all).with(site_token: site.token)

      site.addons
    end
  end

  describe '#kits' do
    it 'returns an array of kits' do
      Kit.should_receive(:all).with(site_token: site.token)

      site.kits
    end
  end

  describe '#packages' do
    before { site.stub(addons: []) }

    it 'returns an array of kits' do
      Package.should_receive(:packages_from_addons).with(site.addons, 'stable')

      site.packages
    end
  end
end
