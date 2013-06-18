class AddNameAndSetNullToTrueToComment < ActiveRecord::Migration
  def change
  	add_column :comments, :user_name, :string
  	change_column :comments, :user_id, :integer, :null => true
  end
end
