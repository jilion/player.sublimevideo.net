require 'fast_spec_helper'

require 'settings_manager'

describe SettingsManager do
  let(:site) { double('site') }
  let(:service) { described_class.new(site, 'stable') }
  let(:settings_file_manager) { double('settings_file_manager') }

  describe '#update' do
    context 'when everything goes well' do
      it 'returns true' do
        SettingsFileManager.should_receive(:new).with(site, 'stable') { settings_file_manager }
        settings_file_manager.should_receive(:upload)
        service.should_receive(:_increment_librato).with('update.succeed')

        service.update.should be_true
      end
    end
  end

  describe '#delete' do
    context 'when everything goes well' do
      it 'returns true' do
        SettingsFileManager.should_receive(:new).with(site, 'stable') { settings_file_manager }
        settings_file_manager.should_receive(:delete)
        service.should_receive(:_increment_librato).with('delete.succeed')

        service.delete
      end
    end
  end
end
