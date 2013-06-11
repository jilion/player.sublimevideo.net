require 'sublime_video_private_api'

class Site
  include SublimeVideoPrivateApi::Model
  uses_private_api :my

  belongs_to :default_kit, class_name: 'Kit'
end
