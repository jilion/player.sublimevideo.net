require 'fast_spec_helper'
require 'config/sidekiq'

require 'player_files_generator_worker'

describe PlayerFilesGeneratorWorker do

  it 'delays job in player queue' do
    described_class.get_sidekiq_options['queue'].should eq 'player'
  end

  context 'event is :settings_update' do
    it 'calls SiteSettingsManager.update only' do
      SiteAppManager.should_not_receive(:perform_async)
      SiteSettingsManager.should_receive(:update).with('abcd1234')

      described_class.new.perform('abcd1234', :settings_update)
    end

    it 'performs async job' do
      expect { described_class.perform_async('abcd1234', :settings_update) }.to change(PlayerFilesGeneratorWorker.jobs, :size).by(1)
    end
  end

  context 'event is :addons_update' do
    it 'calls SiteAppManager.update only' do
      SiteAppManager.should_receive(:update).with('abcd1234')
      SiteSettingsManager.should_not_receive(:update)

      described_class.new.perform('abcd1234', :addons_update)
    end

    it 'performs async job' do
      expect { described_class.perform_async('abcd1234', :addons_update) }.to change(PlayerFilesGeneratorWorker.jobs, :size).by(1)
    end
  end

  context 'event is :cancellation' do
    it 'calls SiteAppManager.delete and SiteSettingsManager.delete' do
      SiteLoaderManager.should_receive(:delete).with('abcd1234')
      SiteSettingsManager.should_receive(:delete).with('abcd1234')

      described_class.new.perform('abcd1234', :cancellation)
    end

    it 'performs async job' do
      expect { described_class.perform_async('abcd1234', :cancellation) }.to change(PlayerFilesGeneratorWorker.jobs, :size).by(1)
    end
  end

end
