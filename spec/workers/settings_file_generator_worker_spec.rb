require 'fast_spec_helper'
require 'config/sidekiq'

require 'settings_file_generator_worker'

SettingsFileGenerator = Class.new unless defined? SettingsFileGenerator

describe SettingsFileGeneratorWorker do
  let(:generator) { stub }
  let(:site) { stub }

  it 'delays job in player queue' do
    described_class.get_sidekiq_options['queue'].should eq 'player'
  end

  it 'calls SettingsFileGenerator' do
    SettingsFileGenerator.should_receive(:update).with('abcd1234', {})

    described_class.new.perform('abcd1234')
  end
end
