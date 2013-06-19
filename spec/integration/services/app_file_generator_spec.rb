require 'spec_helper'

describe AppFileGenerator do
  let(:addon_plan1_hash) do
    {
      'addon' => {
        'name' => 'logo'
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
        'name' => 'logo'
      },
      'name' => 'disabled',
      'title' => 'No SublimeVideo logo',
      'price' => 1990,
      'required_stage' => 'stable'
    }
  end
  let(:kit_hash) do
    {
      'design' => {
        'name' => 'classic'
      },
      'identifier' => 'foo',
      'name' => 'Foo player',
      'settings' => {}
    }
  end
  let!(:package_logo_stable) { create(:package, name: 'logo', version: '1.0.0') }
  let!(:package_logo_beta) { create(:package, name: 'logo', version: '1.0.0-beta') }
  let!(:package_logo_alpha) { create(:package, name: 'logo', version: '1.0.0-alpha') }
  let(:site_token) { 'abcd1234' }
  let(:site_hash) do
    {
      token: site_token
    }
  end
  let(:site) { Site.new(site_hash) }

  before do
    stub_api_for(Site) do |stub|
      stub.get("/private_api/sites/#{site_token}") { |env| [200, {}, site_hash.to_json] }
    end
    stub_api_for(AddonPlan) do |stub|
      stub.get("/private_api/sites/#{site_token}/addons") { |env| [200, {}, [addon_plan1_hash, addon_plan2_hash].to_json] }
    end
    stub_api_for(Kit) do |stub|
      stub.get("/private_api/sites/#{site_token}/kits") { |env| [200, {}, [kit_hash].to_json] }
    end
  end

  describe '#bundle_token' do
    context "with the 'stable' stage" do
      let(:expected_bundle_token) { Digest::MD5.hexdigest(site.packages('stable').sort.to_s) }

      it 'generate a MD5 from the site packages without resolving the dependencies' do
        site.packages('stable').should eq [package_logo_stable]
        PackagesDependenciesSolver.should_not_receive(:dependencies)

        described_class.new(site, 'stable').bundle_token.should eq expected_bundle_token
      end
    end

    context "with the 'beta' stage" do
      let(:expected_bundle_token) { Digest::MD5.hexdigest(site.packages('beta').sort.to_s) }

      it 'generate a MD5 from the site packages without resolving the dependencies' do
        site.packages('beta').should eq [package_logo_beta, package_logo_stable]
        PackagesDependenciesSolver.should_not_receive(:dependencies)

        described_class.new(site, 'beta').bundle_token.should eq expected_bundle_token
      end
    end

    context "with the 'alpha' stage" do
      let(:expected_bundle_token) { Digest::MD5.hexdigest(site.packages('alpha').sort.to_s) }

      it 'generate a MD5 from the site packages without resolving the dependencies' do
        site.packages('alpha').should eq [package_logo_alpha, package_logo_beta, package_logo_stable]
        PackagesDependenciesSolver.should_not_receive(:dependencies)

        described_class.new(site, 'alpha').bundle_token.should eq expected_bundle_token
      end
    end
  end

  pending '#cdn_file' do
  end

  pending '#generate_and_get_token' do
  end

end
