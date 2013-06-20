require 'fast_spec_helper'
require 'config/sidekiq'

require 'site_loader_manager_worker'

describe SiteLoaderManagerWorker do
  let(:generator) { stub }

  it 'delays job in player queue' do
    described_class.get_sidekiq_options['queue'].should eq 'player'
  end

  it 'calls AppManager' do
    SiteLoaderManager.should_receive(:update).with('abcd1234', 'foobar', 'beta', delete: true)

    described_class.new.perform('abcd1234', 'foobar', 'beta', delete: true)
  end
end
