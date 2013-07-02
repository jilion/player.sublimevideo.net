require 'fast_spec_helper'

require 'site_loader_manager'

Site = Class.new unless defined? Site
App = Class.new unless defined? App

describe SiteLoaderManager do
  let(:site) { double('Site', accessible_stage: 'beta') }
  let(:app) { double('App') }
  let(:loader_manager) { double('LoaderManager').as_null_object }

  describe '.update' do
    before do
      Site.should_receive(:find).with('abcd1234') { site }
      App.stub(:find_by_token).with('foobar') { app }
      LoaderManager.stub(:new) { loader_manager }
    end

    context 'no stage given' do
      it 'instantiates a generator for all accessible stages stage' do
        LoaderManager.should_receive(:new).with('abcd1234', app, 'stable').ordered
        LoaderManager.should_receive(:new).with('abcd1234', app, 'beta').ordered

        described_class.update('abcd1234', 'foobar')
      end
    end

    context 'stage given' do
      let(:stage) { 'stable' }
      before { App.should_receive(:find_by_token).with('foobar') { app } }

      it 'instantiate a new loader manager and call #update on it' do
        loader_manager.should_receive(:update).and_return(true)

        described_class.update('abcd1234', 'foobar', 'stable')
      end
    end
  end

  describe '.delete' do
    before do
      Site.should_receive(:find).with('abcd1234') { site }
      App.stub(:find_by_token).with(nil) { nil }
      LoaderManager.stub(:new) { loader_manager }
    end

    it 'instantiate a new loader manager and call #delete on it' do
      loader_manager.should_receive(:delete).and_return(true)

      described_class.delete('abcd1234')
    end
  end

end
