class CreateLoaders < ActiveRecord::Migration
  def change
    create_table :loaders do |t|
      t.string :site_token
      t.references :app_md5, index: true

      t.timestamps
    end
  end
end
