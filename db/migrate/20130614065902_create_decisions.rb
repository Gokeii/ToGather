class CreateDecisions < ActiveRecord::Migration
  def change
    create_table :decisions do |t|
    	t.integer :event_id

      t.timestamps
    end
  end
end
