class AddFkToChoice < ActiveRecord::Migration
  def change
  	add_column :choices, :event_id, :integer
  	add_column :choices, :invitation_id, :integer
  end
end
