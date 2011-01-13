# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

require File.expand_path(File.dirname(__FILE__) + "../../spec/blueprints")

def it_is_foretold
  [true,false].rand
end

# Clients #

4.times { Client.make }
Client.make status: 'Suspended'


# Projects #

for client in Client.all do
  4.times { Project.make client: client }
end


# Tickets #

for project in Project.all do
  4.times { Ticket.make project: project }
end


# Users #

admin_user     = User.make :email => 'admin@xrono.org'
developer_user = User.make :email => 'dev@xrono.org'
locked_user    = User.make :email => 'locked@xrono.org'
client_user    = User.make :email => 'client@xrono.org'

developers = [ admin_user, developer_user ]
8.times { developers.push User.make }


# Roles #

admin_user.has_role!(:admin)

locked_user.lock_access!

for project in Project.all do
  developers.each { |developer| developer.has_role!(:developer, project) if it_is_foretold }
  client_user.has_role!(:client, project) if it_is_foretold
end


# Work Units #

date_range = (( Date.current.monday.advance weeks: -3 )..( Date.current.end_of_week ))
this_friday = Date.current.monday + 4

for date in date_range do
  for user in developers do
    tickets = Ticket.for_user user

    unless tickets.empty?
      4.times { WorkUnit.make user: user,
                              ticket: tickets.rand,
                              scheduled_at: date.to_s,
                              hours_type: 'Normal' } unless date.saturday? or date.sunday? or date == this_friday
    end
  end
end

WorkUnit.scheduled_between(Date.current.advance weeks: -4, Date.current.end_of_week.advance weeks: -2).update_attributes paid: "0987", paid_at: Date.current.to_time, invoiced: "6543", invoiced_at: Date.current.to_time

for user in developers do
  tickets = Ticket.for_user user
  unless tickets.empty?
    WorkUnit.make user: user, ticket: tickets.rand, scheduled_at: date_range.last.to_s, hours_type: 'Overtime', hours: 4
    WorkUnit.make user: user, ticket: tickets.rand, scheduled_at: this_friday.to_s, hours_type: 'CTO', hours: 8
  end
end

Client.make status: 'Inactive'

# Comments #

for client in Client.all do
  4.times { Comment.make user_id: developers.rand.id, commentable_id: client.id }
end
