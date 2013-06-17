require 'fast_spec_helper'
require 'config/sidekiq'

require 'app_file_generator_worker'

describe AppFileGeneratorWorker do
  it 'delays job in player queue' do
    described_class.get_sidekiq_options['queue'].should eq 'player'
  end

  it 'calls AppFileGenerator' do
    AppFileGenerator.should_receive(:update).with('abcd1234')

    described_class.new.perform('abcd1234')
  end
end
