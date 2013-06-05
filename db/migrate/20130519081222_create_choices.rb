class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
    	t.datetime :start_time
    	t.datetime :end_time
    	t.integer :number
    	
      t.timestamps
    end
  end
end
