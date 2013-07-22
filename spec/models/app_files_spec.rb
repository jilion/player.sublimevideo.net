require 'spec_helper'

describe AppFiles do
  let(:controls) { double('classic player controls') }
  let(:sony_player) { double('sony player') }
  let(:app_token) { 'foobar' }
  let(:app_files) { described_class.new(app_token, [controls], 'stable') }
  before do
    controls.stub(:main_file).and_yield(fixture_file(File.join('packages', 'classic-player-controls-1.0.0', 'main.js')))
    sony_player.stub(:main_file).and_yield(fixture_file(File.join('packages', 'sony-player-2.0.0-beta.2', 'main.js')))
    app_files.stub(:_resolved_packages) { [controls, sony_player] }
  end

  describe '#root_path' do
    it 'works' do
      app_files.root_path.should eq Pathname.new("ab/#{app_token}/")
    end
  end

  describe '#main_file_path' do
    it 'works' do
      app_files.main_file_path.should eq "ab/#{app_token}/app.js"
    end
  end

  describe '#main_file_url' do
    it 'works' do
      app_files.main_file_url.should eq "https://#{S3Wrapper.buckets[:sublimevideo]}.s3.amazonaws.com/ab/#{app_token}/app.js"
    end
  end

  describe '#main_file_content' do
    it 'concatenate all the needed package' do
      app_files.main_file_content.read.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        // classic-player-controls 1.0.0
        // sony-player 2.0.0-beta.2
      EOF
    end
  end

end
