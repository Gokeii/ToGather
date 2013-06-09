class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
    	t.string :registration_id, :size => 120, :null => false
    	t.datetime :last_registered_at

      t.timestamps
    end

    add_index :devices, :registration_id, :unique => true
  end
end
