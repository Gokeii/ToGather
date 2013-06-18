class Reply < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :choice_replyships
  has_many :choices, :through => :choice_replyships
  belongs_to :invitation
  belongs_to :event
  belongs_to :user
end
