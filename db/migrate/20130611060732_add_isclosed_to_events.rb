class AddIsclosedToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :is_closed, :boolean
  end
end
