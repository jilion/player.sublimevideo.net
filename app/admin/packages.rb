ActiveAdmin.register Package do
  config.sort_order = 'created_at_desc'

  menu priority: 1

  actions :index, :show

  filter :name, as: :select, collection: proc { Package.pluck(:name).uniq }
  filter :version, as: :select, collection: proc { Package.pluck(:version).uniq }
  # filter :stage, as: :check_boxes, collection: proc { Stage.stages }

  scope :all, :scoped, default: true
  scope :stable
  scope :beta
  scope :alpha

  index do
    column 'Name' do |package|
      link_to package.name, package_path(package)
    end
    column :version
    column 'Zip' do |package|
      link_to "#{package.title}.zip", package_path(package, format: :zip)
    end
    column :created_at
  end

  show title: :title do
    attributes_table do
      row :name
      row :version
      row :zip do
        link_to "#{package.title}.zip", package_path(package, format: :zip)
      end
      row :dependencies
      row :settings
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  controller do
    def show
      show! do |format|
        format.zip { redirect_to @package.zip.url }
      end
    end
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :zip
    end
    f.actions
  end
end
