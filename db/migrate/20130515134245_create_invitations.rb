class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :invitee
      t.string :email

      t.timestamps
    end
  end
end
