require 'spec_helper'

describe LoaderFile do
  let(:site_token) { 'abcd1234' }
  let(:app_token) { 'foobar' }
  let(:loader_file) { described_class.new(site_token, app_token, 'stable') }

  describe '#path' do
    context 'alpha stage' do
      subject { described_class.new(site_token, app_token, 'alpha') }
      its(:path) { "js2/#{app_token}-alpha.js" }
    end

    context 'beta stage' do
      subject { described_class.new(site_token, app_token, 'beta') }
      its(:path) { "js2/#{app_token}-beta.js" }
    end

    context 'stable stage' do
      subject { described_class.new(site_token, app_token, 'stable') }
      its(:path) { "js2/#{app_token}.js" }
    end
  end

  describe '#content' do
    it 'concatenate all the needed package' do
      loader_file.content.read.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        (function(){ c={host:"//cdn.sublimevideo.net",app_token:"foobar",site_token:"abcd1234"}; })();
      EOF
    end
  end

end
