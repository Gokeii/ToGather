class Event < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :choices
  has_many :invitations
  belongs_to :user
  
  scope :between, lambda {|start_time, end_time|
    { :conditions => ["? < start < ?", Event.format_date(start_time), Event.format_date(end_time)] }
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
