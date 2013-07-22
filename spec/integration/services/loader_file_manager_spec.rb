require 'spec_helper'

describe LoaderFileManager do
  let!(:classic_player_controls_1_0_0) { create(:classic_player_controls_1_0_0) }
  let!(:sony_player_1_0_0) { create(:sony_player_1_0_0) }
  let(:app) { create(:app) }
  let(:service) { described_class.new('abcd1234', app.token, 'stable') }
  let(:loader_file_path) { service.send(:_loader_file).path }

  before do
    stub_api_for(AddonPlan) do |stub|
      stub.get("/private_api/sites/abcd1234/addons") { |env| [200, {}, [controls_hash].to_json] }
    end
    stub_api_for(Kit) do |stub|
      stub.get("/private_api/sites/abcd1234/kits") { |env| [200, {}, [kit_hash].to_json] }
    end

    S3Wrapper.delete(S3Wrapper.buckets[:sublimevideo], loader_file_path)
  end

  describe '#update' do
    context 'with non-existing loader' do
      it 'upload the app file' do
        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path) }.to raise_error(Excon::Errors::NotFound)

        service.upload

        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body.should be_present
      end

      it 'returns true' do
        service.upload.should be_true
      end
    end

    context 'with existing loader' do
      before { service.upload }

      it 'does not upload anything' do
        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body.should be_present

        service.upload

        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body.should be_present
      end
    end
  end

  describe '#delete' do
    context 'with a non-existing loader' do
      it 'does nothing' do
        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path) }.to raise_error(Excon::Errors::NotFound)

        service.delete

        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path) }.to raise_error(Excon::Errors::NotFound)
      end
    end

    context 'with existing loader' do
      before { service.upload }

      it 'delete the loader file' do
        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body.should be_present

        service.delete

        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path) }.to raise_error(Excon::Errors::NotFound)
      end
    end
  end

  describe '#loader_file' do
    before { service.upload }

    it 'concatenate all the needed package' do
      loader_file = S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], loader_file_path).body

      loader_file.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        (function(){ c={host:"//cdn.sublimevideo.net",app_token:"#{app.token}",site_token:"abcd1234"}; })();
      EOF
    end

    it 'sets the right headers' do
      loader_file_headers = S3Wrapper.head(S3Wrapper.buckets[:sublimevideo], loader_file_path).headers
      loader_file_headers['Cache-Control'].should eq 's-maxage=300, max-age=120, public'
      loader_file_headers['Content-Type'].should eq 'text/javascript'
    end
  end

end
