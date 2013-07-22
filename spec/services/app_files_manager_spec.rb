require 'spec_helper'

describe AppFilesManager do
  let(:controls) { double('classic player controls') }
  let(:sony_player) { double('sony player') }
  let(:app_token) { 'foobar' }
  let(:cdn_file) { double('CDN file') }
  let(:service) { described_class.new(app_token, [controls, sony_player], 'stable') }

  describe '#upload' do
    before { service.stub(:cdn_app_main_file) { cdn_file } }

    it 'delegates' do
      cdn_file.should_receive(:upload)
      service.should_receive(:_upload_app_assets)

      service.upload
    end
  end

  describe '#delete' do
    it 'delegates' do
      service.should_receive(:_delete_app_files)

      service.delete
    end
  end

  describe '#cdn_app_main_file' do
    before { service.send(:_app_files).stub(:main_file_content) { '' } }

    it 'sets the right headers' do

      service.cdn_app_main_file.headers.should eq({
        'Cache-Control' => 'max-age=29030400, public',
        'Content-Type'  => 'text/javascript',
        'x-amz-acl'     => 'public-read'
      })
    end
  end

  describe '#_app_files' do
    it 'instantiates a new AppFiles object' do
      AppFiles.should_receive(:new).with(app_token, [controls, sony_player], 'stable')

      service.send(:_app_files)
    end
  end

end
