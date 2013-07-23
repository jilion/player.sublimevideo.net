ActiveAdmin.register Loader do
  config.sort_order = 'created_at_desc'

  menu priority: 2

  actions :index, :show

  # filter :app_token
  filter :site_token

  scope :all, :scoped, default: true
  scope :stable
  scope :beta
  scope :alpha

  index do
    column 'App token' do |loader|
      link_to loader.app.token, loader_path(loader)
    end
    column :site_token
    column :stage
    column :updated_at
  end

  show do
    attributes_table do
      row :id
      row :site_token
      row :app do
        link_to loader.app.token, loader.app.files.main_file_url
      end
      row :stage
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  controller do
    # Prevent N+1 queries
    def scoped_collection
      resource_class.includes :app
    end
  end

end
