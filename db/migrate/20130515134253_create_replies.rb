class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|\
    	t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
