# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

require File.expand_path(File.dirname(__FILE__) + "../../spec/blueprints")

4.times { Client.make }
Client.make status: 'Suspended'
Client.make status: 'Inactive'

for client in Client.all do
  4.times { Project.make client: client, name: Faker::Internet.domain_name.humanize }
end

admin = User.make(:email => 'admin@xrono.org', :password => '123456', :password_confirmation => '123456')
dev = User.make(:email => 'dev@xrono.org', :password => '123456', :password_confirmation => '123456')
locked = User.make(:email => 'locked@xrono.org', :password => '123456', :password_confirmation => '123456')
client = User.make(:email => 'client@xrono.org', :password => '123456', :password_confirmation => '123456')

admin.has_role!(:admin)
dev.has_role!(:developer, Client.all.first.projects.first)
dev.has_role!(:developer, Client.all.first.projects.second)
dev.has_role!(:developer, Client.all.second.projects.first)
dev.has_role!(:developer, Client.all.third.projects.first)
locked.lock_access!
client.has_role!(:client, Client.all.first.projects.first)
client.has_role!(:client, Client.all.first.projects.second)
client.has_role!(:client, Client.all.third.projects.third)
client.has_role!(:client, Client.all.fourth.projects.fourth)

8.times { User.make.has_role! :developer, Project.all.shuffle.first }

for project in Project.all do
  4.times { Ticket.make project: project, name: Faker::Lorem.words(2).join(' ').capitalize, description: Faker::Lorem.sentence }
end

users = User.unlocked
clients = Client.not_inactive
tickets = clients.map(&:tickets).flatten
dates = ((Date.current.beginning_of_week - 1.week)..(Date.current.end_of_week))

for user in users do
  unless tickets.empty?
    for date in dates do
      until WorkUnit.scheduled_between(date, date + 1.day).for_user(user).sum(:hours) > 5
        hours = BigDecimal("0.1")*rand(9) + rand(3) + 1
        WorkUnit.create ticket: tickets.shuffle.first, description: Faker::Lorem.paragraph, scheduled_at: date, user: user, hours: hours, hours_type: "Normal"
      end
    end

    3.times do
      date = dates.to_a.shuffle.first
      hours = BigDecimal("0.1")*rand(9) + rand(3) + 1
      WorkUnit.create ticket: tickets.shuffle.first, description: "Overtime", scheduled_at: date, user: user, hours: hours, hours_type: "Overtime"
    end

    date = Date.current.beginning_of_week+4.days
    WorkUnit.scheduled_between(date,date+1.day).for_user(user).destroy_all
    WorkUnit.create ticket: tickets.shuffle.first, description: "National holiday", scheduled_at: date, user: user, hours: 8, hours_type: "CTO"
  end
end
