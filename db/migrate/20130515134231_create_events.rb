class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
    	t.string    :title
      t.string    :description
      t.datetime  :start
      t.datetime  :end
      t.boolean   :all_day

      t.timestamps
    end
  end
end
