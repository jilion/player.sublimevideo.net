require 'fast_spec_helper'
require 'support/fixtures_helpers'

require 'app_manager'

App = Class.new unless defined? App
ActiveRecord = Class.new unless defined?(ActiveRecord)
ActiveRecord::RecordInvalid = Class.new unless defined?(ActiveRecord::RecordInvalid)

describe AppManager do
  let(:controls) { double('classic player controls') }
  let(:sony_player) { double('sony player') }
  let(:original_packages) { [controls] }
  let(:service) { described_class.new('foobar', original_packages, 'stable') }
  let(:app_token) { 'foobar' }
  let(:app_files_manager) { double('app_files_manager') }
  let(:app) { double('App') }
  before do
    controls.stub(:main_file).and_yield(fixture_file(File.join('packages', 'classic-player-controls-1.0.0', 'main.js')))
    sony_player.stub(:main_file).and_yield(fixture_file(File.join('packages', 'sony-player-2.0.0-beta.2', 'main.js')))
  end

  describe '#create' do
    it 'returns true' do
      App.should_receive(:create!).with(token: app_token, packages: original_packages)
      AppFilesManager.should_receive(:new).with('foobar', original_packages, 'stable') { app_files_manager }
      app_files_manager.should_receive(:upload)
      service.should_receive(:_increment_librato).with('create.succeed')

      service.create.should be_true
    end
  end

  describe '#delete' do
    it 'works' do
      App.should_receive(:find_by_token).with(app_token) { app }
      app.should_receive(:destroy!)
      AppFilesManager.should_receive(:new).with('foobar', [], 'stable') { app_files_manager }
      app_files_manager.should_receive(:delete)
      service.should_receive(:_increment_librato).with('delete.succeed')

      service.delete
    end
  end

end
