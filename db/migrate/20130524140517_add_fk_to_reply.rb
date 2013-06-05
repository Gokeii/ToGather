class AddFkToReply < ActiveRecord::Migration
  def change
  	add_column :replies, :invitation_id, :integer
  end
end
