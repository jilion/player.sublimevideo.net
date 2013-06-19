require 'spec_helper'

describe Site do
  let(:site_token) { 'abcd1234' }
  let(:site_hash) do
    {
      token: site_token
    }
  end
  let(:site) { described_class.new(site_hash) }

  describe '.find' do
    before do
      stub_api_for(described_class) do |stub|
        stub.get("/private_api/sites/#{site_token}") { |env| [200, {}, site_hash.to_json] }
      end
    end

    it 'returns a site' do
      described_class.find(site_token).should eq site
    end
  end


  describe '#addon_plans' do
    it 'returns an array of kits' do
      AddonPlan.should_receive(:all).with(site_token: site_token)

      site.addon_plans
    end
  end

  describe '#kits' do
    it 'returns an array of kits' do
      Kit.should_receive(:all).with(site_token: site_token)

      site.kits
    end
  end

  describe '#packages' do
    before do
      site.stub(addon_plans: [
        AddonPlan.new(name: 'sublime', addon: { name: 'logo' }),
        AddonPlan.new(name: 'standard', addon: { name: 'lightbox' })
      ],
      kits: [
        Kit.new(design: { name: 'classic' }),
        Kit.new(design: { name: 'classic' }),
        Kit.new(design: { name: 'flat' })
      ])
    end
    let(:package_1) { double('package 1') }
    let(:package_2) { double('package 2') }

    it 'calls Package#packages_from_addons for each design (only once per design' do
      Package.should_receive(:packages_from_addons).with('classic', %w[logo lightbox], 'stable').once { [package_1, package_2] }
      Package.should_receive(:packages_from_addons).with('flat', %w[logo lightbox], 'stable').once { [package_1, package_2] }

      site.packages.should eq [package_1, package_2]
    end

    it 'accepts a stage' do
      Package.should_receive(:packages_from_addons).with('classic', %w[logo lightbox], 'beta').once { [package_1, package_2] }
      Package.should_receive(:packages_from_addons).with('flat', %w[logo lightbox], 'beta').once { [package_1, package_2] }

      site.packages('beta').should eq [package_1, package_2]
    end
  end
end
