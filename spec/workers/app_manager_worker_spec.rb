require 'fast_spec_helper'
require 'config/sidekiq'

require 'app_manager_worker'

describe AppManagerWorker do
  it 'delays job in player queue' do
    described_class.get_sidekiq_options['queue'].should eq 'player'
  end

  it 'calls AppManager' do
    SiteAppManager.should_receive(:update).with('abcd1234')

    described_class.new.perform('abcd1234')
  end
end
