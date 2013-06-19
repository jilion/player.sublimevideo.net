require 'fast_spec_helper'

require 'loader_file_generator'

Site = Class.new unless defined? Site

describe LoaderFileGenerator do
  let(:site) do
    mock('Site', token: 'abcd1234', hostname: 'google.com',
                 extra_hostnames: 'google.fr, google.ch',
                 staging_hostnames: 'staging.google.com',
                 dev_hostnames: 'staging.google.com',
                 path: 'foo', wildcard: true, accessible_stage: 'stable',
                 default_kit_id: 1)
  end
  let(:kit) do
    mock('Kit', design: { 'name' => 'Classic' }, id: 1, identifier: 'foo',
                name: 'Foo player', settings: {})
  end
  let(:cdn_file) { double('cdn file') }
  let(:service) { described_class.new(site, 'stable') }
  let(:fake_service) { double('service').as_null_object }

  describe '.update' do
    before do
      Site.should_receive(:find).with('abcd1234') { site }
      described_class.stub(:new) { fake_service }
    end

    context 'no stage given' do
      it 'instantiates a generator for each stage' do
        described_class.should_receive(:new).with(site, 'stable', {}).ordered
        described_class.should_receive(:new).with(site, 'beta', {}).ordered
        described_class.should_receive(:new).with(site, 'alpha', {}).ordered

        described_class.update('abcd1234')
      end
    end

    context 'stage given' do
      let(:stage) { 'stable' }

      it 'instantiates a generator' do
        described_class.should_receive(:new).with(site, stage, {})

        described_class.update('abcd1234', stage: stage)
      end

      context 'no options' do
        it 'calls #update on the generator' do
          fake_service.should_receive(:update)

          described_class.update('abcd1234', stage: stage)
        end
      end

      context 'options = { delete: true }' do
        it 'calls #update on the generator' do
          fake_service.should_receive(:update)

          described_class.update('abcd1234', stage: stage, delete: true)
        end
      end
    end
  end

  describe '#update' do
    context ':delete option is not set' do
      let(:service) { described_class.new(site, 'stable')}

      it 'calls #generate' do
        service.should_receive(:generate)

        service.update
      end
    end

    context ':delete option is set' do
      let(:service) { described_class.new(site, 'stable', delete: true)}

      it 'calls #delete' do
        service.should_receive(:delete)

        service.update
      end
    end
  end

  describe '#generate' do
    it 'upload the cdn file' do
      service.should_receive(:cdn_file) { cdn_file }
      cdn_file.should_receive(:upload)

      service.generate
    end
  end

  describe '#delete' do
    it 'delete the cdn file' do
      CDNFile.should_receive(:new).with(nil, "js/#{site.token}.js", nil) { cdn_file }
      cdn_file.should_receive(:delete)

      service.delete
    end
  end

  pending '#cdn_file' do
  end

  describe '#token' do
    context ':token option is set' do
      let(:service) { described_class.new(site, 'stable', bundle_token: 'foobar')}

      it 'returns the given app_bundle' do
        service.bundle_token.should eq 'foobar'
      end
    end
  end

end
