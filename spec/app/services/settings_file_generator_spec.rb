require 'fast_spec_helper'
require 'settings_file_generator'

# force_define_rails!

describe SettingsFileGenerator do
  let(:site) do
    Site.new('token' => 'abcd1234',
            'hostname' => 'google.com',
            'extra_hostnames' => 'google.fr, google.ch',
            'staging_hostnames' => 'staging.google.com',
            'dev_hostnames' => 'staging.google.com',
            'path' => 'foo',
            'wildcard' => true,
            'accessible_stage' => 'stable',
            'default_kit_id' => 1)
  end
  let(:kit) do
    Kit.new('design' => { 'name' => 'Classic' },
            'id' => 1,
            'identifier' => 'foo',
            'name' => 'Foo player',
            'settings' => {})
  end
  let(:service) { described_class.new(site) }

  describe '#generate_and_upload' do
    it 'gets all the site kits', :focus do
      puts "Rails.root : #{Rails.root}"
      Kit.should_receive(:all).with(site_token: 'abcd1234')

      service.generate_and_upload
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

  describe '#kits' do
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

end
