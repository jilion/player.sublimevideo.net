require 'fast_spec_helper'

require 'site_settings_manager'

Site = Class.new unless defined? Site

describe SiteSettingsManager do
  let(:site) { double('Site', accessible_stage: 'beta') }
  let(:settings_manager) { double('SettingsManager').as_null_object }

  describe '.update' do
    before do
      Site.should_receive(:find).with('abcd1234') { site }
      SettingsManager.stub(:new) { settings_manager }
    end

    context 'no stage given' do
      it 'instantiates a generator for all accessible stages' do
        SettingsManager.should_receive(:new).with(site, 'stable').ordered
        SettingsManager.should_receive(:new).with(site, 'beta').ordered

        described_class.update('abcd1234')
      end
    end

    context 'stage given' do
      it 'instantiate a new loader manager and call #update on it' do
        settings_manager.should_receive(:update).and_return(true)

        described_class.update('abcd1234', 'beta')
      end
    end
  end

  describe '.delete' do
    before do
      Site.should_receive(:find).with('abcd1234') { site }
      SettingsManager.stub(:new) { settings_manager }
    end

    it 'instantiate a new loader manager and call #delete on it' do
      settings_manager.should_receive(:delete).and_return(true)

      described_class.delete('abcd1234')
    end
  end

end
