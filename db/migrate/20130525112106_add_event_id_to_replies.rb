class AddEventIdToReplies < ActiveRecord::Migration
  def change
  	add_column :replies, :event_id, :integer
  end
end
