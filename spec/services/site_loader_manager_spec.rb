require 'fast_spec_helper'

require 'site_loader_manager'

Site = Class.new unless defined? Site
App = Class.new unless defined? App

describe SiteLoaderManager do
  let(:site) do
    mock('Site', token: 'abcd1234', hostname: 'google.com',
                 extra_hostnames: 'google.fr, google.ch',
                 staging_hostnames: 'staging.google.com',
                 dev_hostnames: 'staging.google.com',
                 path: 'foo', wildcard: true, accessible_stage: 'stable',
                 default_kit_id: 1)
  end
  let(:app) { double('app') }
  let(:kit) do
    mock('Kit', design: { 'name' => 'Classic' }, id: 1, identifier: 'foo',
                name: 'Foo player', settings: {})
  end
  let(:cdn_file) { double('cdn file') }
  let(:service) { described_class.new(site, 'stable') }
  let(:fake_service) { double('SiteLoaderManager').as_null_object }
  let(:loader_manager) { double('LoaderManager').as_null_object }

  describe '.update' do
    before do
      Site.should_receive(:find).with('abcd1234') { site }
      App.stub(:find_by_token)
      described_class.stub(:new) { fake_service }
      fake_service.should_receive(:update)
    end

    context 'no stage given' do
      it 'instantiates a generator for each stage' do
        described_class.should_receive(:new).with(site, nil, 'stable', {}).ordered
        described_class.should_receive(:new).with(site, nil, 'beta', {}).ordered
        described_class.should_receive(:new).with(site, nil, 'alpha', {}).ordered

        described_class.update('abcd1234')
      end
    end

    context 'stage given' do
      let(:stage) { 'stable' }
      before { App.should_receive(:find_by_token).with('foobar') { app } }

      it 'instantiates a generator' do
        described_class.should_receive(:new).with(site, app, stage, {})

        described_class.update('abcd1234', 'foobar', stage)
      end

      context 'no options' do
        it 'calls #update on the generator' do
          described_class.should_receive(:new).with(site, app, stage, {})

          described_class.update('abcd1234', 'foobar', stage)
        end
      end

      context 'options = { delete: true }' do
      it 'instantiates the manager with given noptions' do
          described_class.should_receive(:new).with(site, app, stage, delete: true)

          described_class.update('abcd1234', 'foobar', stage, delete: true)
        end
      end
    end
  end

  describe '#update' do
    before { LoaderManager.should_receive(:new).with(site, app, 'stable').and_return(loader_manager) }

    context ':delete option is not set' do
      let(:service) { described_class.new(site, app, 'stable') }

      it 'calls #update' do
        loader_manager.should_receive(:update).and_return(true)

        service.update
      end
    end

    context ':delete option is set' do
      let(:service) { described_class.new(site, app, 'stable', delete: true)}

      it 'calls #delete' do
        loader_manager.should_receive(:delete).and_return(true)

        service.update
      end
    end
  end

end
