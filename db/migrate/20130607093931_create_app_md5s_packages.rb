class CreateAppMd5sPackages < ActiveRecord::Migration
  def change
    create_table :app_md5s_packages, id: false do |t|
      t.references :app_md5, index: true
      t.references :package, index: true
    end
  end
end
