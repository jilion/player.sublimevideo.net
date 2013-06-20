require 'fast_spec_helper'
require 'rails/railtie'
require 'config/carrierwave' # for fog_mock
require 'support/fixtures_helpers'

require 'cdn_file'

describe CDNFile, :fog_mock do
  let(:file) { fixture_file(File.join('packages', 'classic-player-controls-1.0.0', 'main.js'), 'r') }
  let(:file2) { fixture_file(File.join('packages', 'classic-player-controls-1.0.0', 'addons_settings', 'controls.json'), 'r') }
  let(:path) { "js/token.js" }
  let(:headers) { {
    'Cache-Control' => 'max-age=60, public', # 2 minutes
    'Content-Type'  => 'text/javascript',
    'x-amz-acl'     => 'public-read'
  } }
  let(:cdn_file) { CDNFile.new(file, path, headers) }
  before { S3Wrapper.delete(S3Wrapper.buckets[:sublimevideo], path) }

  describe "#upload" do
    it "uploads files" do
      cdn_file.should_not be_present
      cdn_file.upload
      cdn_file.should be_present
    end

    describe "s3 object(s)" do
      before { cdn_file.upload }

      it "is public" do
        object_acl = S3Wrapper.send(:_fog_connection).get_object_acl(S3Wrapper.buckets[:sublimevideo], path).body
        object_acl['AccessControlList'].should include(
          {"Permission"=>"READ", "Grantee"=>{"URI"=>"http://acs.amazonaws.com/groups/global/AllUsers"}}
        )
      end
      it "have good content_type public" do
        object_headers = S3Wrapper.head(S3Wrapper.buckets[:sublimevideo], path).headers
        object_headers['Content-Type'].should eq 'text/javascript'
      end
      it "have 5 min max-age cache control" do
        object_headers = S3Wrapper.head(S3Wrapper.buckets[:sublimevideo], path).headers
        object_headers['Cache-Control'].should eq 'max-age=60, public'
      end
      it "have ETag" do
        object_headers = S3Wrapper.head(S3Wrapper.buckets[:sublimevideo], path).headers
        object_headers['ETag'].should be_present
      end
    end

    describe "respond" do
      it "is true when file wasn't present before" do
        cdn_file.upload.should be_true
      end

      it "is true when an other file is present" do
        cdn_file.upload
        cdn_file.file = file2
        cdn_file.upload.should be_true
      end
    end
  end

  describe "#delete" do
    context "with file present" do
      before { cdn_file.upload }

      it "remove S3 object" do
        cdn_file.delete
        cdn_file.should_not be_present
      end

      it "returns true" do
        cdn_file.delete.should be_true
      end
    end
  end

end
