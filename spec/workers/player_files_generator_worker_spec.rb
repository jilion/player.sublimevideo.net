require 'fast_spec_helper'
require 'config/sidekiq'

require 'player_files_generator_worker'

describe PlayerFilesGeneratorWorker do

  it 'delays job in player queue' do
    described_class.get_sidekiq_options['queue'].should eq 'player'
  end

  context 'event is :settings' do
    it 'delays SettingsFileGeneratorWorker only' do
      AppFileGeneratorWorker.should_not_receive(:perform_async)
      SettingsFileGeneratorWorker.should_receive(:perform_async).with('abcd1234')

      described_class.new.perform('abcd1234', :settings)
    end

    it 'performs async job' do
      expect { described_class.perform_async('abcd1234', :settings) }.to change(PlayerFilesGeneratorWorker.jobs, :size).by(1)
    end
  end

  context 'event is :addons' do
    it 'delays SettingsFileGeneratorWorker only' do
      AppFileGeneratorWorker.should_receive(:perform_async).with('abcd1234')
      SettingsFileGeneratorWorker.should_not_receive(:perform_async)

      described_class.new.perform('abcd1234', :addons)
    end

    it 'performs async job' do
      expect { described_class.perform_async('abcd1234', :addons) }.to change(PlayerFilesGeneratorWorker.jobs, :size).by(1)
    end
  end

end
