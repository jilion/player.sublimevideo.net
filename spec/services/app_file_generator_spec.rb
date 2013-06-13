require 'fast_spec_helper'
require 'support/fixtures_helpers'

require 'app_file_generator'

Package = Class.new unless defined? Package

describe AppFileGenerator do
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
  let(:app) { mock('app package', file: fixture_file(File.join('packages', 'app-1.0.0', 'main.js'))) }
  let(:logo) { mock('logo package', file: fixture_file(File.join('packages', 'logo-2.0.0-beta.2', 'main.js'))) }
  let(:service) { described_class.new(site, 'stable') }

  describe '#generate_and_upload' do
    let(:cdn_file) { mock('cdn file') }

    it 'upload the cdn file' do
      service.should_receive(:cdn_file) { cdn_file }
      cdn_file.should_receive(:upload)

      service.generate_and_upload
    end
  end

  describe '#packages' do
    before do
      service.should_receive(:_dependencies) { [['app', '1.0.0'], ['logo', '2.0.0-beta.2']] }
      Package.should_receive(:find_by_name_and_version).with('app', '1.0.0') { app }
      Package.should_receive(:find_by_name_and_version).with('logo', '2.0.0-beta.2') { logo }
    end

    it 'returns the array of packages corrsponding to the #_dependencies' do
      service.packages.should eq [app, logo]
    end
  end

  describe '#cdn_file' do
    before { service.should_receive(:packages) { [app, logo] } }

    it 'concatenate all the needed package' do
      service.cdn_file.file.read.should eq <<-EOF.gsub(/^\s+/, '')
        // app 1.0.0
        // logo 2.0.0-beta.2
      EOF
    end
  end

end
