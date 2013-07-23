require 'spec_helper'

describe AppManager do
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

  describe '#create' do
    context 'with non-existing app' do
      it 'creates an app' do
        expect { service.create }.to change(App, :count).by(1)
      end

      it 'upload the app file' do
        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], app_file_path) }.to raise_error(Excon::Errors::NotFound)

        service.create

        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], app_file_path).body.should be_present
      end

      it 'uploads all packages assets' do
        service.create

        site.packages('stable').each do |package|
          package.assets do |assets|
            assets.each do |asset|
              expect {
                path = service.send(:_path).join("#{package.name}/#{asset[:name]}").to_s
                file = S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], path)
                file.headers['Cache-Control'].should eq 'max-age=29030400, public'
                file.headers['Content-Type'].should eq MIME::Types.type_for(asset[:name]).first.to_s
              }.to_not raise_error(Excon::Errors::NotFound)
            end
          end
        end
      end

      it 'returns true' do
        service.create.should be_true
      end
    end

    context 'with existing app' do
      before { service.create }

      it 'does not create an app' do
        expect { service.create }.to_not change(App, :count)
      end

      it 'does not upload anything' do
        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], app_file_path).body.should be_present

        service.create

        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], app_file_path).body.should be_present
      end

      it 'returns false' do
        service.create.should be_false
      end
    end
  end

  describe '#delete' do
    context 'with a non-existing app' do
      it 'does nothing' do
        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], app_file_path) }.to raise_error(Excon::Errors::NotFound)

        expect { service.delete }.to_not change(App, :count)

        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], app_file_path) }.to raise_error(Excon::Errors::NotFound)
      end
    end

    context 'with existing app' do
      before { service.create }

      it 'destroys the app' do
        expect { service.delete }.to change(App, :count).by(-1)
      end

      it 'deletes the app file' do
        S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], app_file_path).body.should be_present

        service.delete

        expect { S3Wrapper.get(S3Wrapper.buckets[:sublimevideo], app_file_path) }.to raise_error(Excon::Errors::NotFound)
      end

      it 'delete all packages assets' do
        service.delete

        S3Wrapper.all(S3Wrapper.buckets[:sublimevideo], prefix: app_files.root_path.to_s).files.should be_empty
      end
    end
  end

end
