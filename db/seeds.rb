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

4.times { Project.make }

# for client in Client.all do
#   Project.make 3, name: Faker::Internet.domain_name.humanize
# end

