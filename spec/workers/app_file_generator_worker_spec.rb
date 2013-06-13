require 'fast_spec_helper'
require 'config/sidekiq'

require 'app_file_generator_worker'

AppFileGenerator = Class.new unless defined? AppFileGenerator

describe AppFileGeneratorWorker do
  let(:generator) { stub }

  it 'delays job in player queue' do
    described_class.get_sidekiq_options['queue'].should eq 'player'
  end

  it 'calls AppFileGenerator' do
    AppFileGenerator.should_receive(:new) { generator }
    generator.should_receive(:generate_and_upload)

    described_class.new.perform('abcd1234')
  end
end