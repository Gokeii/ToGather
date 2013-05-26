class CreateChoiceReplyships < ActiveRecord::Migration
  def change
    create_table :choice_replyships do |t|
    	t.integer :choice_id
    	t.integer :reply_id
      t.timestamps
    end
  end
end
