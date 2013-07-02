require 'spec_helper'

describe SettingsFileManager do
  let(:site) { Site.new(site_hash) }
  let(:service) { described_class.new(site, 'stable') }
  let(:settings_file_path) { service.send(:_path) }

  before do
    stub_api_for(AddonPlan) do |stub|
      stub.get("/private_api/sites/abcd1234/addons") { |env| [200, {}, [controls_hash].to_json] }
    end
    stub_api_for(Kit) do |stub|
      stub.get("/private_api/sites/abcd1234/kits") { |env| [200, {}, [kit_hash].to_json] }
    end

    S3Wrapper.delete(S3Wrapper.buckets[:sublimevideo], settings_file_path)
  end

  describe '#update' do
    context 'with non-existing settings' do
      it 'upload the app file' do
        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], settings_file_path) }.to raise_error(Excon::Errors::NotFound)

        service.upload

        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], settings_file_path).body.should be_present
      end

      it 'returns true' do
        service.upload.should be_true
      end
    end

    context 'with existing settings' do
      before { service.upload }

      it 'does not upload anything' do
        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], settings_file_path).body.should be_present

        service.upload

        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], settings_file_path).body.should be_present
      end
    end
  end

  describe '#delete' do
    context 'with a non-existing settings' do
      it 'does nothing' do
        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], settings_file_path) }.to raise_error(Excon::Errors::NotFound)

        service.delete

        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], settings_file_path) }.to raise_error(Excon::Errors::NotFound)
      end
    end

    context 'with existing settings' do
      before { service.upload }

      it 'delete the settings file' do
        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], settings_file_path).body.should be_present

        service.delete

        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], settings_file_path) }.to raise_error(Excon::Errors::NotFound)
      end
    end
  end

  describe '#settings_file' do
    before { service.upload }

    it 'concatenate all the needed package' do
      settings_file = S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], settings_file_path).body

      settings_file.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings  | (c) 2013 Jilion SA | http://sublimevideo.net
        */(function(){ sublime_.define("settings",[],function(){var e,t,i;return t={},e={},i={license:{"hosts":["google.com","google.fr","google.ch"],"wildcard":true,"path":"foo","stage":"stable","stagingHosts":["staging.google.com"],"devHosts":["staging.google.com"]},app:{},kits:{"foo":{"skin":{"module":"sony-player/sony"},"plugins":{"controls":{"enabled":false}}}},defaultKit:"foo"},t.exports=i,t.exports||e});;sublime_.component('settings');})();
      EOF
    end

    it 'sets the right headers' do
      settings_file_headers = S3Wrapper.head(S3Wrapper.buckets[:sublimevideo], settings_file_path).headers
      settings_file_headers['Cache-Control'].should eq 's-maxage=300, max-age=120, public'
      settings_file_headers['Content-Type'].should eq 'text/javascript'
    end
  end

end
