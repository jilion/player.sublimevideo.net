require 'spec_helper'

describe LoaderFileManager do
  let(:service) { described_class.new('abcd1234', 'foobar', 'stable') }

  describe '#loader_file' do
    context 'stable stage' do
      it 'has the right path' do
        service.loader_file.path.to_s.should eq "js2/abcd1234.js"
      end
    end

    context '"beta" stage' do
      let(:service) { described_class.new('abcd1234', 'foobar', 'beta') }

      it 'has the right path' do
        service.loader_file.path.to_s.should eq "js2/abcd1234-beta.js"
      end
    end

    context '"alpha" stage' do
      let(:service) { described_class.new('abcd1234', 'foobar', 'alpha') }

      it 'has the right path' do
        service.loader_file.path.to_s.should eq "js2/abcd1234-alpha.js"
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
