require 'fast_spec_helper'

require 'settings_file_generator'

Site = Class.new unless defined? Site

describe SettingsFileGenerator do
  let(:site) do
    double('Site', token: 'abcd1234', hostname: 'google.com',
                   extra_hostnames: 'google.fr, google.ch',
                   staging_hostnames: 'staging.google.com',
                   dev_hostnames: 'staging.google.com',
                   path: 'foo', wildcard: true, accessible_stage: 'stable',
                   default_kit_id: 1)
  end
  let(:kit) do
    double('Kit', design: { 'name' => 'Classic' }, id: 1, identifier: 'foo',
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
    it 'gets all the site kits' do
      service.should_receive(:cdn_file) { cdn_file }
      cdn_file.should_receive(:upload)

      service.generate
    end
  end

  describe '#delete' do
    it 'gets all the site kits' do
      CDNFile.should_receive(:new).with(nil, "s3/#{site.token}.js", nil) { cdn_file }
      cdn_file.should_receive(:delete)

      service.delete
    end
  end

  describe '#license' do
    it 'generate the license hash' do
      service.license.should eq({
        hosts: %w[google.com google.fr google.ch],
        staging_hosts: %w[staging.google.com],
        dev_hosts: %w[staging.google.com],
        path: 'foo',
        wildcard: true,
        stage: 'stable'
      })
    end
  end

  pending '#kits' do
    it 'generate the license hash' do
      service.kits.should eq({
        "1" => {
          skin: { module: 'foo/bar' },
          plugins: {
            "addon_kind1" => {
              plugins: {
                "addon_kind2" => {
                  settings: {
                    close_button_position: "right"
                  },
                  allowed_settings: {
                    close_button_position: {
                      values: ["left", "right"]
                    }
                  },
                  id: "plugin2_1", :module => "foo/bar2"
                }
              },
              settings: {
                autoplay: false
              },
              allowed_settings: {
                autoplay: {
                  values: [true, false]
                }
              },
              id: "plugin1", :module => "foo/bar"
            }
          }
        },
        "2" => {
          skin: { module: 'foo/bar2' },
          plugins: {
            "addon_kind1" => {
              plugins: {
                "addon_kind2" => {
                  settings: {
                    close_button_position: "left"
                  },
                  allowed_settings: {
                    close_button_position: {
                      values: ["left", "right"]
                    }
                  },
                  id: "plugin2_2", :module => "foo/bar3"
                }
              },
              settings: {
                autoplay: true
              },
              allowed_settings: {
                autoplay: {
                  values: [true, false]
                }
              },
              id: "plugin1", :module => "foo/bar"
            }
          }
        }
      })

    end
  end

  pending '#cdn_file' do
    before do
      service.should_receive(:_dependencies) { [['classic-player-controls', '1.0.0'], ['sony-player', '2.0.0-beta.2']] }
      Package.should_receive(:find_by_name_and_version).with('classic-player-controls', '1.0.0') { controls }
      Package.should_receive(:find_by_name_and_version).with('sony-player', '2.0.0-beta.2') { sony_player }
      # service.should_receive(:packages) { [controls, sony_player] }
      service.should_receive(:_md5) { 'abcd1234' }
    end

    it 'concatenate all the needed package' do
      service.cdn_file.file.read.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        /*! SublimeVideo settings | (c) 2013 Jilion SA | http://sublimevideo.net */
        // classic-player-controls 1.0.0
        // sony-player 2.0.0-beta.2
      EOF
    end

    it 'uses the md5 as path' do
      service.cdn_file.path.should eq 's3/abcd1234.js'
    end

    it 'sets the right headers' do
      service.cdn_file.headers.should eq({
        'Cache-Control' => 's-maxage=300, max-age=120, public',
        'Content-Type'  => 'text/javascript',
        'x-amz-acl'     => 'public-read'
      })
    end
  end


end
