require 'spec_helper'

describe LoaderManager do
  let!(:classic_player_controls_1_0_0) { create(:classic_player_controls_1_0_0) }
  let!(:sony_player_1_0_0) { create(:sony_player_1_0_0) }
  let(:site_hash) { { token: 'abcd1234' } }
  let(:site) { Site.new(site_hash) }
  let(:app) { create(:app) }
  let(:service) { described_class.new(site, app, 'stable') }
  let(:loader_file_path) { service.send(:_path) }

  before do
    stub_api_for(AddonPlan) do |stub|
      stub.get("/private_api/sites/#{site.token}/addons") { |env| [200, {}, [controls_hash].to_json] }
    end
    stub_api_for(Kit) do |stub|
      stub.get("/private_api/sites/#{site.token}/kits") { |env| [200, {}, [kit_hash].to_json] }
    end

    S3Wrapper.delete(S3Wrapper.buckets[:sublimevideo], loader_file_path)
  end

  describe '#update' do
    context 'with non-existing loader' do
      it 'creates an app bundle' do
        expect { service.update }.to change(Loader, :count).by(1)
      end

      it 'upload the app file' do
        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path) }.to raise_error(Excon::Errors::NotFound)

        service.update

        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body.should be_present
      end

      it 'returns true' do
        service.update.should be_true
      end
    end

    context 'with existing loader' do
      before { service.update }

      it 'does not create an app bundle' do
        expect { service.update }.to_not change(Loader, :count)
      end

      it 'does not upload anything' do
        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body.should be_present

        service.update

        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body.should be_present
      end
    end
  end

  describe '#delete' do
    context 'with a non-existing loader' do
      it 'does nothing' do
        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path) }.to raise_error(Excon::Errors::NotFound)

        expect { service.delete }.to_not change(Loader, :count)

        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path) }.to raise_error(Excon::Errors::NotFound)
      end
    end

    context 'with existing loader' do
      before { service.update }

      it 'destroy the loader' do
        expect { service.delete }.to change(Loader, :count).by(-1)
      end

      it 'delete the loader file' do
        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body.should be_present

        service.delete

        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path) }.to raise_error(Excon::Errors::NotFound)
      end
    end
  end

  describe '#loader_file' do
    before { service.update }

    it 'concatenate all the needed package' do
      loader_file = S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body

      loader_file.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        (function(){ c={host:"//cdn.sublimevideo.net",app_token:"#{app.token}",site_token:"#{site.token}"}; })();
      EOF
    end

    it 'sets the right headers' do
      loader_file_headers = S3Wrapper.head(S3Wrapper.buckets[:sublimevideo], loader_file_path).headers
      loader_file_headers['Cache-Control'].should eq 's-maxage=300, max-age=120, public'
      loader_file_headers['Content-Type'].should eq 'text/javascript'
    end
  end

end
