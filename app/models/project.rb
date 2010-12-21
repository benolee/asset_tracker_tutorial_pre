class Project < ActiveRecord::Base
  include GuidReferenced
  acts_as_commentable
  acts_as_authorization_object

  belongs_to :client
  has_many :tickets
  has_many :comments, :as => :commentable
  has_many :file_attachments

  validates_presence_of :name
  validates_presence_of :client_id
  validates_uniqueness_of :name, :scope => :client_id

  scope :sort_by_name, order('name ASC')
  scope :for_client, lambda {|client| where :client_id => client.id }

  def self.for_user(user)
    select {|p| p.allows_access?(user) }
  end

  def work_units
    WorkUnit.for_project(self)
  end

  def hours
    work_units.map(&:hours).sum
  end

  def uninvoiced_hours
    work_units.where(:invoiced => nil).map(&:hours).sum
  end

  def to_s
    name
  end

  def allows_access?(user)
    accepts_roles_by?(user) || user.admin?
  end

end
