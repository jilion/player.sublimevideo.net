require 'fast_spec_helper'

require 'loader_manager'

Loader = Class.new unless defined? Loader

describe LoaderManager do
  let(:app) { double('app', token: 'foobar') }
  let(:service) { described_class.new('abcd1234', app, 'stable') }
  let(:loader) { double('loader', :'app=' => true, save!: true) }
  let(:loader_file_manager) { double('loader_file_manager') }

  describe '#update' do
    context 'when everything goes well' do
      it 'returns true' do
        Loader.should_receive(:find_or_initialize_by).with(site_token: 'abcd1234', stage: 'stable').and_return(loader)
        LoaderFileManager.should_receive(:new).with('abcd1234', 'foobar', 'stable') { loader_file_manager }
        loader_file_manager.should_receive(:upload)
        service.should_receive(:_increment_librato).with('update.succeed')

        service.update.should be_true
      end
    end
  end

  describe '#delete' do
    context 'when everything goes well' do
      it 'returns true' do
        Loader.should_receive(:find_by).with(site_token: 'abcd1234', stage: 'stable').and_return(loader)
        loader.should_receive(:destroy!).and_return(true)
        LoaderFileManager.should_receive(:new).with('abcd1234', 'foobar', 'stable') { loader_file_manager }
        loader_file_manager.should_receive(:delete)
        service.should_receive(:_increment_librato).with('delete.succeed')

        service.delete
      end
    end
  end

end
