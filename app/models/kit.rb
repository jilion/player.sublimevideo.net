require 'sublime_video_private_api'

class Kit
  include SublimeVideoPrivateApi::Model
  uses_private_api :my
  collection_path '/private_api/sites/:site_token/kits'

  belongs_to :site
end
