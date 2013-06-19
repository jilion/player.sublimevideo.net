require 'sublime_video_private_api'

class AddonPlan
  include SublimeVideoPrivateApi::Model

  uses_private_api :my
  collection_path '/private_api/sites/:site_token/addons'

end
