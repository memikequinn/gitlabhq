class CreateVapors < ActiveRecord::Migration
  def change
    create_table :vapors do |t|
      t.string :path
      t.integer :tier
      t.boolean :default

      t.timestamps
    end
  end
end
