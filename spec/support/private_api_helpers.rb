require 'sublime_video_private_api/spec_helper'
RSpec.configure do |config|
  config.include SublimeVideoPrivateApi::SpecHelper
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
      'name' => 'sony'
    },
    'identifier' => 'foo',
    'name' => 'Foo player',
    'settings' => {}
  }
end
