require 'spec_helper'

require 'site'

describe SiteAppManager do
  let!(:classic_player_controls_1_0_0) { create(:classic_player_controls_1_0_0) }
  let!(:sony_player_1_0_0) { create(:sony_player_1_0_0) }
  let!(:sony_player_2_0_0_alpha) { create(:sony_player_2_0_0_alpha) }
  let(:site_token) { 'abcd1234' }
  let(:site) { Site.new(token: site_token) }
  let(:service) { described_class.new(site, 'stable') }

  before do
    stub_api_for(AddonPlan) do |stub|
      stub.get("/private_api/sites/#{site_token}/addons") { |env| [200, {}, [controls_hash].to_json] }
    end
    stub_api_for(Kit) do |stub|
      stub.get("/private_api/sites/#{site_token}/kits") { |env| [200, {}, [kit_hash].to_json] }
    end
  end

  describe '#app_token' do
    context "with the 'stable' stage" do
      let(:expected_app_token) { Digest::MD5.hexdigest(site.packages('stable').map(&:title).sort.to_s) }

      it 'generate a MD5 from the site packages without resolving the dependencies' do
        site.packages('stable').should eq [sony_player_1_0_0]
        PackagesDependenciesSolver.should_not_receive(:dependencies)

        described_class.new(site, 'stable').app_token.should eq expected_app_token
      end
    end

    context "with the 'beta' stage" do
      let(:expected_app_token) { Digest::MD5.hexdigest(site.packages('beta').map(&:title).sort.to_s) }

      it 'generate a MD5 from the site packages without resolving the dependencies' do
        site.packages('beta').should eq [sony_player_1_0_0]
        PackagesDependenciesSolver.should_not_receive(:dependencies)

        described_class.new(site, 'beta').app_token.should eq expected_app_token
      end
    end

    context "with the 'alpha' stage" do
      let(:expected_app_token) { Digest::MD5.hexdigest(site.packages('alpha').map(&:title).sort.to_s) }

      it 'generate a MD5 from the site packages without resolving the dependencies' do
        site.packages('alpha').should eq [sony_player_2_0_0_alpha, sony_player_1_0_0]
        PackagesDependenciesSolver.should_not_receive(:dependencies)

        described_class.new(site, 'alpha').app_token.should eq expected_app_token
      end
    end

    it 'is fast to compute' do
      start = Time.now

      service.app_token

      expect(Time.now - start).to be < 0.02
    end
  end

  describe '#find_or_create' do
    context 'app does not exist' do
      it 'creates it' do
        service.app.should be_nil

        service.find_or_create

        service.app.should be_present
      end
    end

    context 'app already exists' do
      before { service.find_or_create }

      it 'updates the loader' do
        service.app.should be_present

        AppManager.should_not_receive(:new)

        service.find_or_create
      end
    end
  end

end
