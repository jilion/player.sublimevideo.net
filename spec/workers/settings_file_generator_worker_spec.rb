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

  it 'calls AppFileGenerator' do
    Site.should_receive(:find).with('abcd1234') { site }
    SettingsFileGenerator.should_receive(:new).with(site) { generator }
    generator.should_receive(:generate_and_upload)

    described_class.new.perform('abcd1234')
  end
end
