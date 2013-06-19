require 'fast_spec_helper'
require 'support/fixtures_helpers'

require 'app_file_generator'

Site = Class.new unless defined? Site
Package = Class.new unless defined? Package
AppBundle = Class.new unless defined? AppBundle
Loader = Class.new unless defined? Loader

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
  let(:controls) { double('classic player controls') }
  let(:sony_player) { double('sony player') }
  let(:service) { described_class.new(site, 'stable') }
  let(:fake_service) { double('service') }
  let(:cdn_file) { double('cdn file') }
  let(:bundle_token) { 'foobar' }

  before do
    controls.stub(:main_file).and_yield(fixture_file(File.join('packages', 'classic-player-controls-1.0.0', 'main.js')))
    sony_player.stub(:main_file).and_yield(fixture_file(File.join('packages', 'sony-player-2.0.0-beta.2', 'main.js')))
  end

  describe '.update' do
    it 'calls .update_for_stage for each stage' do
      Stage.stages.each do |stage|
        described_class.should_receive(:update_for_stage).with('123', stage)
      end

      described_class.update('123')
    end
  end

  describe '.update_for_stage' do
    before do
      Site.should_receive(:find).with('123') { site }
      described_class.stub(:new) { fake_service }
      service.stub(:generate_and_get_bundle_token) { bundle_token }
      LoaderFileGeneratorWorker.stub(:perform_async)
    end

    it 'initializes a generator' do
      described_class.should_receive(:new).with(site, 'stable')

      described_class.update_for_stage('123', 'stable')
    end

    context 'stage is "stable"' do
      let(:stage) { 'stable' }

      it 'calls #generate_and_get_bundle_token on the generator' do
        service.should_receive(:generate_and_get_bundle_token) { bundle_token }

        described_class.update_for_stage('123', stage)
      end

      it 'delays LoaderFileGeneratorWorker.perform_async' do
        service.should_receive(:generate_and_get_bundle_token) { bundle_token }
        LoaderFileGeneratorWorker.should_receive(:perform_async).with('123', stage: stage, bundle_token: bundle_token)

        described_class.update_for_stage('123', stage)
      end
    end

    context 'stage is "beta"' do
      let(:stage) { 'beta' }

      it 'does not call #generate_and_get_bundle_token on the generator' do
        service.should_not_receive(:generate_and_get_bundle_token) { bundle_token }

        described_class.update_for_stage('123', stage)
      end

      it 'does not delay LoaderFileGeneratorWorker.perform_async' do
        service.should_not_receive(:generate_and_get_bundle_token) { bundle_token }
        LoaderFileGeneratorWorker.should_not_receive(:perform_async)

        described_class.update_for_stage('123', stage)
      end
    end

    context 'stage is "alpha"' do
      let(:stage) { 'alpha' }

      it 'does not call #generate_and_get_bundle_token on the generator' do
        service.should_not_receive(:generate_and_get_bundle_token) { bundle_token }

        described_class.update_for_stage('123', stage)
      end

      it 'does not delay LoaderFileGeneratorWorker.perform_async' do
        service.should_not_receive(:generate_and_get_bundle_token) { bundle_token }
        LoaderFileGeneratorWorker.should_not_receive(:perform_async)

        described_class.update_for_stage('123', stage)
      end
    end
  end

  describe '#bundle_token' do
    before { site.stub(:packages).and_return(%w[b a]) }
    let(:expected_bundle_token) { Digest::MD5.hexdigest(%w[a b].to_s) }

    it 'generate a MD5 from the site packages without resolving the dependencies' do
      PackagesDependenciesSolver.should_not_receive(:dependencies)

      described_class.new(site, 'stable').bundle_token.should eq expected_bundle_token
    end
  end

  describe '#cdn_file' do
    before do
      service.should_receive(:_resolved_packages) { [controls,  sony_player] }
      service.should_receive(:bundle_token) { 'abcd1234' }
    end

    it 'concatenate all the needed package' do
      service.cdn_file.file.read.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        // classic-player-controls 1.0.0
        // sony-player 2.0.0-beta.2
      EOF
    end

    it 'uses the bundle_token as path' do
      service.cdn_file.path.should eq 'app/abcd1234.js'
    end

    it 'sets the right headers' do
      service.cdn_file.headers.should eq({
        'Cache-Control' => 's-maxage=300, max-age=120, public',
        'Content-Type'  => 'text/javascript',
        'x-amz-acl'     => 'public-read'
      })
    end
  end

  describe '#_path' do
    before do
      service.should_receive(:bundle_token) { 'abcd1234' }
    end

    it 'sets the right path' do
      service.send(:_path).should eq 'app/abcd1234.js'
    end
  end

  describe '#generate_and_get_bundle_token' do
    let(:original_packages) { double('AppBundle') }
    let(:app_bundle) { double('AppBundle') }
    before do
      service.stub(:bundle_token).and_return(bundle_token)
      service.stub(:_original_packages) { original_packages }
      Loader.stub(:create)
    end

    context 'with non-existing app bundle' do
      before do
        service.should_receive(:_app_bundle).at_least(:twice).and_return(nil)
      end

      it 'upload the cdn file' do
        AppBundle.should_receive(:create!).with(token: bundle_token, packages: original_packages).and_return(true)
        service.should_receive(:cdn_file) { cdn_file }
        cdn_file.should_receive(:upload)

        service.generate_and_get_bundle_token.should eq bundle_token
      end
    end

    context 'with an existing app bundle' do
      before do
        service.should_receive(:_app_bundle).at_least(:twice).and_return(app_bundle)
        AppBundle.should_not_receive(:create!)
      end

      it 'does not upload anything and return the bundle_token' do
        service.should_not_receive(:_create_loader!)
        service.should_not_receive(:cdn_file)

        service.generate_and_get_bundle_token.should eq bundle_token
      end
    end
  end

end
