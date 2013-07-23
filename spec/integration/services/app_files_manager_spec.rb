require 'spec_helper'

describe AppFilesManager do
  let!(:classic_player_controls_1_0_0) { create(:classic_player_controls_1_0_0) }
  let!(:sony_player_1_0_0) { create(:sony_player_1_0_0) }
  let(:site_token) { 'abcd1234' }
  let(:site_hash) { { token: site_token } }
  let(:site) { Site.new(site_hash) }
  let(:service) { described_class.new('foobar', site.packages('stable'), 'stable') }
  let(:app_files) { AppFiles.new('foobar', site.packages('stable'), 'stable') }
  let(:app_file_path) { app_files.main_file_path }

  before do
    stub_api_for(AddonPlan) do |stub|
      stub.get("/private_api/sites/#{site_token}/addons") { |env| [200, {}, [controls_hash].to_json] }
    end
    stub_api_for(Kit) do |stub|
      stub.get("/private_api/sites/#{site_token}/kits") { |env| [200, {}, [kit_hash].to_json] }
    end

    S3Wrapper.all(S3Wrapper.buckets[:sublimevideo], prefix: app_files.root_path.to_s).files.each { |file| file.destroy }
  end

  describe '#cdn_app_main_file' do
    before { service.upload }

    it 'concatenate all the needed package' do
      cdn_app_main_file = S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], app_file_path).body

      cdn_app_main_file.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        // sony-player 1.0.0
        // classic-player-controls 1.0.0
      EOF
    end

    it 'sets the right headers' do
      app_file_headers = S3Wrapper.head(S3Wrapper.buckets[:sublimevideo], app_file_path).headers
      app_file_headers['Cache-Control'].should eq 'max-age=29030400, public'
      app_file_headers['Content-Type'].should eq 'text/javascript'
    end
  end

end
