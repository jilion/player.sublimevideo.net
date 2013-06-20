require 'fast_spec_helper'

require 'loader_manager'

Loader = Class.new unless defined? Loader
ActiveRecord = Class.new unless defined?(ActiveRecord)
ActiveRecord::RecordInvalid = Class.new(StandardError) # FIXME: unless defined?(ActiveRecord::RecordInvalid)

describe LoaderManager do
  let(:site_token) { 'abcd1234' }
  let(:app_token) { 'foobar' }
  let(:site) { double('site', token: site_token) }
  let(:app) { double('app', token: app_token) }
  let(:service) { described_class.new(site, app, 'stable') }
  let(:loader) { double('loader', :'app=' => true, save!: true) }

  describe '#update' do
    context 'when everything goes well' do
      it 'returns true' do
        Loader.should_receive(:find_or_initialize_by).with(site_token: site_token, stage: 'stable').and_return(loader)
        service.should_receive(:_upload_loader_file)
        service.should_receive(:_increment_librato).with('update.succeed')

        service.update.should be_true
      end
    end
  end

  describe '#delete' do
    context 'when everything goes well' do
      it 'returns true' do
        Loader.should_receive(:find_by).with(site_token: site_token, stage: 'stable').and_return(loader)
        loader.should_receive(:destroy!).and_return(true)
        service.should_receive(:_delete_loader_file)
        service.should_receive(:_increment_librato).with('delete.succeed')

        service.delete
      end
    end
  end

  describe '#loader_file' do
    context 'stable stage' do
      it 'has the right path' do
        service.loader_file.path.to_s.should eq "js2/#{site_token}.js"
      end
    end

    context '"beta" stage' do
      let(:service) { described_class.new(site, app, 'beta') }

      it 'has the right path' do
        service.loader_file.path.to_s.should eq "js2/#{site_token}-beta.js"
      end
    end

    context '"alpha" stage' do
      let(:service) { described_class.new(site, app, 'alpha') }

      it 'has the right path' do
        service.loader_file.path.to_s.should eq "js2/#{site_token}-alpha.js"
      end
    end

    it 'concatenate all the needed package' do
      service.loader_file.file.read.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        (function(){ c={host:"//cdn.sublimevideo.net",app_token:"foobar",site_token:"abcd1234"}; })();
      EOF
    end

    it 'sets the right headers' do
      service.loader_file.headers.should eq({
        'Cache-Control' => 's-maxage=300, max-age=120, public',
        'Content-Type'  => 'text/javascript',
        'x-amz-acl'     => 'public-read'
      })
    end
  end

end
