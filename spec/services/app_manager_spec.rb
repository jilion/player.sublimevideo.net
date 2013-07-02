require 'fast_spec_helper'
require 'support/fixtures_helpers'

require 'app_manager'

App = Class.new unless defined? App
ActiveRecord = Class.new unless defined?(ActiveRecord)
ActiveRecord::RecordInvalid = Class.new(StandardError) # FIXME: unless defined?(ActiveRecord::RecordInvalid)

describe AppManager do
  let(:controls) { double('classic player controls') }
  let(:sony_player) { double('sony player') }
  let(:original_packages) { [controls] }
  let(:service) { described_class.new('foobar', original_packages, 'stable') }
  let(:app_token) { 'foobar' }
  before do
    controls.stub(:main_file).and_yield(fixture_file(File.join('packages', 'classic-player-controls-1.0.0', 'main.js')))
    sony_player.stub(:main_file).and_yield(fixture_file(File.join('packages', 'sony-player-2.0.0-beta.2', 'main.js')))
  end

  describe '#create' do
    before do
      service.stub(:app_token).and_return(app_token)
    end

    context 'when everything goes well' do
      it 'returns true' do
        App.should_receive(:create!).with(token: app_token, packages: original_packages)
        service.should_receive(:_upload_app_file)
        service.should_receive(:_upload_app_assets)
        service.should_receive(:_increment_librato).with('create.succeed')

        service.create.should be_true
      end
    end

    context 'when app bundle is not valid' do
      it 'returns true' do
        App.should_receive(:create!).with(token: app_token, packages: original_packages).and_raise(ActiveRecord::RecordInvalid)
        service.should_not_receive(:_upload_app_file)
        service.should_not_receive(:_upload_app_assets)
        service.should_receive(:_increment_librato).with('create.failed')

        service.create.should be_false
      end
    end
  end

  describe '#app_file' do
    before do
      service.should_receive(:_resolved_packages) { [controls,  sony_player] }
    end

    it 'has the right path' do
      service.app_file.path.to_s.should eq "ab/#{app_token}/app.js"
    end

    it 'concatenate all the needed package' do
      service.app_file.file.read.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        // classic-player-controls 1.0.0
        // sony-player 2.0.0-beta.2
      EOF
    end

    it 'sets the right headers' do
      service.app_file.headers.should eq({
        'Cache-Control' => 'max-age=29030400, public',
        'Content-Type'  => 'text/javascript',
        'x-amz-acl'     => 'public-read'
      })
    end
  end

end
