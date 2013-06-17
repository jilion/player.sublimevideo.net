require 'fast_spec_helper'
require 'support/fixtures_helpers'

require 'app_file_generator'

Site = Class.new unless defined? Site
Package = Class.new unless defined? Package
AppMd5 = Class.new unless defined? AppMd5

describe AppFileGenerator do
  let(:site) do
    double('Site', token: 'abcd1234', hostname: 'google.com',
                   extra_hostnames: 'google.fr, google.ch',
                   staging_hostnames: 'staging.google.com',
                   dev_hostnames: 'staging.google.com',
                   path: 'foo', wildcard: true, accessible_stage: 'stable',
                   default_kit_id: 1)
  end
  let(:kit) do
    double('Kit', design: { 'name' => 'Classic' }, id: 1, identifier: 'foo',
                  name: 'Foo player', settings: {})
  end
  let(:controls) { double('classic player controls', file: fixture_file(File.join('packages', 'classic-player-controls-1.0.0', 'main.js'))) }
  let(:sony_player) { double('sony player', file: fixture_file(File.join('packages', 'sony-player-2.0.0-beta.2', 'main.js'))) }
  let(:service) { described_class.new(site, 'stable') }
  let(:fake_service) { double('service') }
  let(:cdn_file) { double('cdn file') }
  let(:md5) { double('md5', md5: 'abcd1234') }

  describe '.update_for_stage' do
    before do
      Site.should_receive(:find).with('123') { site }
      described_class.stub(:new) { fake_service }
      service.stub(:generate_and_get_md5) { md5 }
      LoaderFileGeneratorWorker.stub(:perform_async)
    end

    it 'initializes a generator' do
      described_class.should_receive(:new).with(site, 'stable')

      described_class.update_for_stage('123', 'stable')
    end

    context 'stage is "stable"' do
      let(:stage) { 'stable' }

      it 'calls #generate_and_get_md5 on the generator' do
        service.should_receive(:generate_and_get_md5) { md5 }

        described_class.update_for_stage('123', stage)
      end

      it 'delays LoaderFileGeneratorWorker.perform_async' do
        service.should_receive(:generate_and_get_md5) { md5 }
        LoaderFileGeneratorWorker.should_receive(:perform_async).with('123', stage: stage, app_md5: md5)

        described_class.update_for_stage('123', stage)
      end
    end

    context 'stage is "beta"' do
      let(:stage) { 'beta' }

      it 'does not call #generate_and_get_md5 on the generator' do
        service.should_not_receive(:generate_and_get_md5) { md5 }

        described_class.update_for_stage('123', stage)
      end

      it 'does not delay LoaderFileGeneratorWorker.perform_async' do
        service.should_not_receive(:generate_and_get_md5) { md5 }
        LoaderFileGeneratorWorker.should_not_receive(:perform_async)

        described_class.update_for_stage('123', stage)
      end
    end

    context 'stage is "alpha"' do
      let(:stage) { 'alpha' }

      it 'does not call #generate_and_get_md5 on the generator' do
        service.should_not_receive(:generate_and_get_md5) { md5 }

        described_class.update_for_stage('123', stage)
      end

      it 'does not delay LoaderFileGeneratorWorker.perform_async' do
        service.should_not_receive(:generate_and_get_md5) { md5 }
        LoaderFileGeneratorWorker.should_not_receive(:perform_async)

        described_class.update_for_stage('123', stage)
      end
    end
  end

  describe '#generate_and_get_md5' do
    let(:arel) { double }
    before do
      service.should_receive(:_md5).at_least(:twice).and_return(md5)
      AppMd5.should_receive(:where) { arel }
    end

    context 'with no existing MD5' do
      before { arel.should_receive(:exists?).and_return(false) }

      it 'upload the cdn file' do
        service.should_receive(:cdn_file) { cdn_file }
        cdn_file.should_receive(:upload)

        service.generate_and_get_md5.should eq md5
      end
    end

    context 'with an existing MD5' do
      before { arel.should_receive(:exists?).and_return(true) }

      it 'does not upload anything and return the md5' do
        service.should_not_receive(:cdn_file)

        service.generate_and_get_md5.should eq md5
      end
    end
  end

  describe '#cdn_file' do
    before do
      service.should_receive(:_dependencies) { [['classic-player-controls', '1.0.0'], ['sony-player', '2.0.0-beta.2']] }
      Package.should_receive(:find_by_name_and_version).with('classic-player-controls', '1.0.0') { controls }
      Package.should_receive(:find_by_name_and_version).with('sony-player', '2.0.0-beta.2') { sony_player }
      # service.should_receive(:packages) { [controls, sony_player] }
      service.should_receive(:_md5) { 'abcd1234' }
    end

    it 'concatenate all the needed package' do
      service.cdn_file.file.read.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        // classic-player-controls 1.0.0
        // sony-player 2.0.0-beta.2
      EOF
    end

    it 'uses the md5 as path' do
      service.cdn_file.path.should eq 's3/abcd1234.js'
    end

    it 'sets the right headers' do
      service.cdn_file.headers.should eq({
        'Cache-Control' => 's-maxage=300, max-age=120, public',
        'Content-Type'  => 'text/javascript',
        'x-amz-acl'     => 'public-read'
      })
    end
  end

end
