class CreateAppMd5s < ActiveRecord::Migration
  def change
    create_table :app_md5s do |t|
      t.string :md5

      t.timestamps
    end
    add_index :app_md5s, :md5
  end
end
