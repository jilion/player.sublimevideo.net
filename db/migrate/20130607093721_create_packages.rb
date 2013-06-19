class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.string :version
      t.string :zip
      t.json :dependencies
      t.json :settings

      t.timestamps
    end
    add_index :packages, :name
    add_index :packages, [:name, :version], unique: true
  end
end
