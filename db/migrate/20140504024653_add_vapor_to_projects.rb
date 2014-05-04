class AddVaporToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :vapor_id, :integer
  end
end
