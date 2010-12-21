class Ticket < ActiveRecord::Base
  include GuidReferenced
  acts_as_commentable
  belongs_to :project
  has_many :work_units
  has_many :file_attachments

  validates_presence_of :project_id
  validates_presence_of :name

  scope :for_client, lambda{|client| joins({:project => [:client]}).where(:client_id => client.id) }
  scope :for_project, lambda {|project| where(:project_id => project.id) }
  scope :sort_by_name, order('name ASC')

  def self.for_user(user)
    select {|t| t.allows_access?(user) }
  end

  def client
    project.client
  end

  def to_s
    name
  end

  def hours
    work_units.map(&:hours).sum
  end

  def unpaid_hours
    work_units.where(:paid => nil).map(&:hours).sum
  end

  def uninvoiced_hours
    work_units.where(:invoiced => nil).map(&:hours).sum
  end

  def long_name
    "Ticket: [#{id}] - #{project.name} - #{name} ticket for #{client.name}"
  end

  def allows_access?(user)
    project.accepts_roles_by?(user) || user.admin?
  end

end
