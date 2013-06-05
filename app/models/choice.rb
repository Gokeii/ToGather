class Choice < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :choice_replyships
  has_many :replies, :through => :choice_replyships
  belongs_to :event
end
