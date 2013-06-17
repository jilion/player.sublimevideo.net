require 'fast_spec_helper'
require 'config/sidekiq'

require 'loader_file_generator_worker'

LoaderFileGenerator = Class.new unless defined? LoaderFileGeneratorWorker

describe LoaderFileGeneratorWorker do
  let(:generator) { stub }

  it 'delays job in player queue' do
    described_class.get_sidekiq_options['queue'].should eq 'player'
  end

  it 'calls AppFileGenerator' do
    LoaderFileGenerator.should_receive(:update).with('abcd1234', {})

    described_class.new.perform('abcd1234')
  end
end
