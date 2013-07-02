require 'sublime_video_private_api/spec_helper'
RSpec.configure do |config|
  config.include SublimeVideoPrivateApi::SpecHelper
end

def site_hash
  {
    'token' => 'abcd1234', 'hostname' => 'google.com',
    'extra_hostnames' => 'google.fr, google.ch',
    'staging_hostnames' => 'staging.google.com',
    'dev_hostnames' => 'staging.google.com',
    'path' => 'foo', 'wildcard' => true, 'accessible_stage' => 'stable',
    'default_kit' => kit_hash
  }
end

def controls_hash
  {
    'addon' => {
      'name' => 'controls'
    },
    'name' => 'standard',
    'title' => 'Controls',
    'price' => 0,
    'required_stage' => 'stable'
  }
end

def kit_hash
  {
    'design' => {
      'name' => 'sony',
      'module' => 'sony-player/sony'
    },
    'identifier' => 'foo',
    'name' => 'Foo player',
    'settings' => {
      'controls' => {
        'enabled' => false
      }
    }
  }
end
