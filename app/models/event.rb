class Event < ActiveRecord::Base
  attr_accessible :title, :location, :description, :emails
  has_many :choices
  has_many :invitations
  has_many :replies
  has_one :decision
  belongs_to :user

  acts_as_commentable
  
  scope :between, lambda {|start_time, end_time|
    { :conditions => ["start BETWEEN ? AND ?", Event.format_date(start_time), Event.format_date(end_time)] }
  }

  def self.format_date(date_time)
  	Time.at(date_time.to_i).to_formatted_s(:db)
  end

  def as_json(options = {})
  {
  	:id => self.id,
  	:title => self.title,
  	:description => self.description || "",
  	:start => self.start.rfc822,
  	:end => self.end.rfc822,
  	:allDay => self.all_day,
  	:recurring => false,
  	:url => Rails.application.routes.url_helpers.event_path(self),
  }
  end
end
