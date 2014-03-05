#Conferences are the main administrative resource, they define a bunch of settings
#and own conference items (which are what users)
class Conference < ActiveRecord::Base
  has_paper_trail 
  
  attr_accessible :conference_year, :tax_rate, :conference_items_attributes, :active

  has_many :conference_items
  has_many :line_items, :through => :conference_items
  has_many :discounts
  has_many :itineraries
  has_many :proposals, :through => :itineraries
  has_one :schedule
  has_many :rooms, :through => :schedule
  has_many :slots, :through => :schedule
  
  accepts_nested_attributes_for :conference_items, allow_destroy: true
  
  validates :tax_rate, :numericality => {
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 1
  }
  after_create :build_schedule
  
  
  #returns the number of proposals scoped to this conference
  def proposal_count
    proposals.count
  end
  
  #returns the number of line_items scoped to this model
  #Note: this statistic is not the same as the number of people registered
  def registration_count
    line_items.count
  end

  def registration_breakdown
    @report = [];
    @conference_items = conference_items
    @conference_items.each do |item|
      @report << [item.name, item.line_items.where(paid: true).count]
    end
    return @report
  end

  # essentially a named scope, but implemented as a class method beecause scopes must be chainable and find_by_x isn't chainable
  def self.active
    find_by_active(true)
  end
  
  private
  #creates a schedule for this conference
  def build_schedule
    build_schedule(:conference_id => id)
  end
end
