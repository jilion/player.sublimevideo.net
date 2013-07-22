require 'spec_helper'

describe LoaderFileManager do
  let(:cdn_file) { double('CDN file') }
  let(:service) { described_class.new('abcd1234', 'foobar', 'stable') }

  describe '#upload' do
    before { service.stub(:cdn_loader_file) { cdn_file } }

    it 'delegates' do
      cdn_file.should_receive(:upload)

      service.upload
    end
  end

  describe '#delete' do
    it 'delegates' do
      CDNFile.should_receive(:new).with(nil, service.send(:_loader_file).path, nil) { cdn_file }
      cdn_file.should_receive(:delete)

      service.delete
    end
  end

  describe '#cdn_loader_file' do
    before { service.send(:_loader_file).stub(:content) { '' } }

    it 'sets the right headers' do
      service.cdn_loader_file.headers.should eq({
        'Cache-Control' => 's-maxage=300, max-age=120, public',
        'Content-Type'  => 'text/javascript',
        'x-amz-acl'     => 'public-read'
      })
    end
  end

end
