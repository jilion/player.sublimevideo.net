require 'spec_helper'

describe PackageManager do
  let(:sony_player_2_0_0_alpha) { build(:sony_player_2_0_0_alpha) }
  let(:site1) { Site.new(site_hash.merge('token' => '1')) }
  let(:site2) { Site.new(site_hash.merge('token' => '2')) }
  let(:site3) { Site.new(site_hash.merge('token' => '3')) }
  let(:service) { described_class.new(sony_player_2_0_0_alpha) }

  before do
    app1 = create(:app, packages: [create(:sony_player_1_0_0)])
    app2 = create(:app, packages: [create(:classic_player_controls_1_0_0)])
    create(:loader, app: app1, site_token: site1.token)
    create(:loader, app: app1, site_token: site2.token)
    create(:loader, app: app2, site_token: site3.token)
  end

  describe '#create' do
    it 'creates a new package' do
      expect { service.create }.to change(Package, :count).by(1)
    end

    it 'delays the update of the app and settings for sites that may depend on this package' do
      [site1, site2].each do |site|
        SiteAppManager.should delay(:update, queue: 'player').with(site.token)
        SiteSettingsManager.should delay(:update, queue: 'player').with(site.token)
      end

      service.create
    end

    it 'delays Campfire message' do
      CampfireWrapper.should delay(:post)

      service.create
    end

    it 'returns true' do
      service.create.should be_true
    end
  end

end
