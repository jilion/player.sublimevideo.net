require 'spec_helper'

describe AppFileGenerator do
  let(:controls_hash) do
    {
      'addon' => {
        'name' => 'controls'
      },
      'name' => 'standard',
      'title' => 'Controls',
      'price' => 0,
      'required_stage' => 'stable'
    }
  end
  let(:kit_hash) do
    {
      'design' => {
        'name' => 'sony'
      },
      'identifier' => 'foo',
      'name' => 'Foo player',
      'settings' => {}
    }
  end
  let!(:classic_player_controls_1_0_0) { create(:classic_player_controls_1_0_0) }
  let!(:sony_player_1_0_0) { create(:sony_player_1_0_0) }
  let!(:sony_player_2_0_0_alpha) { create(:sony_player_2_0_0_alpha) }
  let(:site_token) { 'abcd1234' }
  let(:site_hash) do
    {
      token: site_token
    }
  end
  let(:site) { Site.new(site_hash) }
  let(:service) { described_class.new(site, 'stable') }

  before do
    stub_api_for(Site) do |stub|
      stub.get("/private_api/sites/#{site_token}") { |env| [200, {}, site_hash.to_json] }
    end
    stub_api_for(AddonPlan) do |stub|
      stub.get("/private_api/sites/#{site_token}/addons") { |env| [200, {}, [controls_hash].to_json] }
    end
    stub_api_for(Kit) do |stub|
      stub.get("/private_api/sites/#{site_token}/kits") { |env| [200, {}, [kit_hash].to_json] }
    end
  end

  describe '#bundle_token' do
    context "with the 'stable' stage" do
      let(:expected_bundle_token) { Digest::MD5.hexdigest(site.packages('stable').sort.to_s) }

      it 'generate a MD5 from the site packages without resolving the dependencies' do
        site.packages('stable').should eq [sony_player_1_0_0]
        PackagesDependenciesSolver.should_not_receive(:dependencies)

        described_class.new(site, 'stable').bundle_token.should eq expected_bundle_token
      end
    end

    context "with the 'beta' stage" do
      let(:expected_bundle_token) { Digest::MD5.hexdigest(site.packages('beta').sort.to_s) }

      it 'generate a MD5 from the site packages without resolving the dependencies' do
        site.packages('beta').should eq [sony_player_1_0_0]
        PackagesDependenciesSolver.should_not_receive(:dependencies)

        described_class.new(site, 'beta').bundle_token.should eq expected_bundle_token
      end
    end

    context "with the 'alpha' stage" do
      let(:expected_bundle_token) { Digest::MD5.hexdigest(site.packages('alpha').sort.to_s) }

      it 'generate a MD5 from the site packages without resolving the dependencies' do
        site.packages('alpha').should eq [sony_player_2_0_0_alpha, sony_player_1_0_0]
        PackagesDependenciesSolver.should_not_receive(:dependencies)

        described_class.new(site, 'alpha').bundle_token.should eq expected_bundle_token
      end
    end
  end

  describe '#bundle_token' do
    it 'is fast to compute' do
      start = Time.now

      service.bundle_token

      expect(Time.now - start).to be < 200
    end
  end

  describe '#cdn_file' do
    before { service.generate_and_get_bundle_token }

    it 'concatenate all the needed package' do
      app_file = S3Wrapper.get("app/#{service.bundle_token}.js").body

      app_file.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        // sony-player 1.0.0
        // classic-player-controls 1.0.0
      EOF
    end

    pending 'sets the right headers' do
      app_file_headers = S3Wrapper.head("app/#{service.bundle_token}.js").headers
      puts app_file_headers.inspect
      app_file_headers['Cache-Control'].should eq 's-maxage=300, max-age=120, public'
      app_file_headers['Content-Type'].should eq 'text/javascript'
      app_file_headers['x-amz-acl'].should eq 'public-read'
    end
  end

  describe '#generate_and_get_token' do
    context 'with non-existing app bundle' do
      it 'creates an app bundle' do
        expect { service.generate_and_get_bundle_token }.to change(AppBundle, :count).by(1)
      end

      it 'upload the app file' do
        expect { S3Wrapper.get("app/#{service.bundle_token}.js") }.to raise_error(Excon::Errors::NotFound)

        service.generate_and_get_bundle_token

        S3Wrapper.get("app/#{service.bundle_token}.js").body.should be_present
      end

      it 'creates a loader and only one' do
        expect { service.generate_and_get_bundle_token }.to change(Loader, :count).by(1)

        loader = Loader.last
        loader.app_bundle.should eq AppBundle.last
        loader.site_token.should eq site.token

        expect { service.generate_and_get_bundle_token }.to_not change(Loader, :count).by(1)
      end

      it 'returns the app bundle token' do
        service.generate_and_get_bundle_token.should eq AppBundle.last.token
      end
    end

    context 'with existing app bundle' do
      before do
        AppBundle.create!(token: service.bundle_token, packages: site.packages('stable'))
      end

      it 'does not create an app bundle' do
        expect { service.generate_and_get_bundle_token }.to_not change(AppBundle, :count)
      end

      it 'does not upload anything' do
        expect { S3Wrapper.get("app/#{service.bundle_token}.js") }.to raise_error(Excon::Errors::NotFound)

        service.generate_and_get_bundle_token

        expect { S3Wrapper.get("app/#{service.bundle_token}.js") }.to raise_error(Excon::Errors::NotFound)
      end

      it 'creates a loader and only one' do
        expect { service.generate_and_get_bundle_token }.to change(Loader, :count).by(1)

        loader = Loader.last
        loader.app_bundle.should eq AppBundle.last
        loader.site_token.should eq site.token

        expect { service.generate_and_get_bundle_token }.to_not change(Loader, :count).by(1)
      end

      it 'returns the app bundle token' do
        service.generate_and_get_bundle_token.should eq service.bundle_token
      end
    end
  end

end
