require 'fast_spec_helper'

require 'site_app_manager'

Site = Class.new unless defined? Site
Loader = Class.new unless defined? Loader

describe SiteAppManager do
  let(:site) { double('Site', token: 'abcd1234', accessible_stage: 'stable') }
  let(:controls) { double('classic player controls', title: 'controls-1.0.0') }
  let(:sony_player) { double('sony player', title: 'sony-player-2.0.0-beta.2') }
  let(:service) { described_class.new(site, 'stable') }
  let(:fake_service) { double('fake service') }
  let(:app_token) { 'foobar' }
  let(:app) { double('App', token: app_token) }

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
      fake_service.stub(:find_or_create) { app }
      SiteLoaderManagerWorker.stub(:perform_async)
    end

    it 'initializes a manager' do
      described_class.should_receive(:new).with(site, 'stable')

      described_class.update_for_stage('123', 'stable')
    end

    context 'stage is "stable"' do
      let(:stage) { 'stable' }
      before { service.should_receive(:find_or_create).and_return(app) }

      it 'calls #find_or_create on the manager' do
        described_class.update_for_stage('123', stage)
      end

      it 'delays SiteLoaderManagerWorker.perform_async' do
        SiteLoaderManagerWorker.should_receive(:perform_async).with('123', app.token, stage)

        described_class.update_for_stage('123', stage)
      end
    end

    context 'stage is "beta"' do
      let(:stage) { 'beta' }

      it 'does not call #find_or_create on the manager' do
        service.should_not_receive(:find_or_create)

        described_class.update_for_stage('123', stage)
      end

      it 'does not delay SiteLoaderManagerWorker.perform_async' do
        service.should_not_receive(:find_or_create)
        SiteLoaderManagerWorker.should_not_receive(:perform_async)

        described_class.update_for_stage('123', stage)
      end
    end

    context 'stage is "alpha"' do
      let(:stage) { 'alpha' }

      it 'does not call #find_or_create on the manager' do
        service.should_not_receive(:find_or_create)

        described_class.update_for_stage('123', stage)
      end

      it 'does not delay SiteLoaderManagerWorker.perform_async' do
        service.should_not_receive(:find_or_create)
        SiteLoaderManagerWorker.should_not_receive(:perform_async)

        described_class.update_for_stage('123', stage)
      end
    end
  end

  describe '#app_token' do
    before { site.stub(:packages).and_return([controls, sony_player]) }
    let(:expected_app_token) { Digest::MD5.hexdigest([controls.title, sony_player.title].to_s) }

    it 'generate a MD5 from the site packages without resolving the dependencies' do
      PackagesDependenciesSolver.should_not_receive(:dependencies)

      described_class.new(site, 'stable').app_token.should eq expected_app_token
    end
  end

  describe '#find_or_create' do
    let(:original_packages) { [] }
    let(:app_manager) { double('AppManager') }
    before do
      service.stub(:app_token).and_return(app_token)
      service.stub(:_original_packages) { original_packages }
      AppManager.stub(:new).and_return(stub(create: true))
    end

    context 'with non-existing app bundle' do
      before do
        service.should_receive(:app).ordered.and_return(nil)
        service.should_receive(:app).ordered.and_return(app)
      end

      it 'upload the cdn file' do
        AppManager.should_receive(:new).with(app_token, original_packages, 'stable').and_return(app_manager)
        app_manager.should_receive(:create)

        service.find_or_create.should eq app
      end
    end

    context 'with an existing app bundle' do
      before do
        service.should_receive(:app).twice.and_return(app)
        AppManager.should_not_receive(:new)
      end

      it 'does not upload anything and return the app_token' do
        service.should_not_receive(:cdn_file)

        service.find_or_create.should eq app
      end
    end
  end

end
