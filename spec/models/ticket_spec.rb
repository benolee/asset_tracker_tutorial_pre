require 'spec_helper'

describe Ticket do
  let(:ticket){ Ticket.new }
  subject{ ticket }

  it "should allow comments" do
    subject.respond_to?(:comments).should be true
  end

  context 'validations' do
    it "fails validation with no project_id" do
      should have(1).errors_on(:project_id)
    end

    it "fails validation with no name" do
      should have(1).errors_on(:name)
    end
  end

  context 'when dealing with associations' do
    it "should belong to a project" do
      should belong_to(:project)
    end

    it "should have many work units" do
      should have_many(:work_units)
    end
  end

  describe 'while being created' do
    it 'should create a new ticket from the blueprint' do
      lambda do
        Ticket.make
      end.should change(Ticket, :count).by(1)
    end
  end

  describe '.client' do
    context 'when a ticket exists' do
      it 'returns the client' do
        ticket = Ticket.make
        ticket.client.should == ticket.project.client
      end
    end
  end

  describe '.unpaid_hours' do
    context 'when there are unpaid work units on a ticket' do
      it 'totals the unpaid hours for that ticket' do
        ticket = Ticket.make
        work_unit_1 = WorkUnit.make(:ticket => ticket)
        work_unit_2 = WorkUnit.make(:ticket => ticket)
        work_unit_3 = WorkUnit.make(
          :ticket => ticket,
          :paid => 'paid on 2010-10-25')
        unpaid_hours = work_unit_1.effective_hours + work_unit_2.effective_hours
        ticket.unpaid_hours.should == unpaid_hours
      end
    end
  end

  describe '.uninvoiced_hours' do
    context 'when there are uninvoiced work units on a ticket' do
      it 'returns the total number of uninvoiced work units for that ticket' do
        ticket = Ticket.make
        work_unit_1 = WorkUnit.make(:ticket => ticket)
        work_unit_2 = WorkUnit.make(:ticket => ticket)
        work_unit_3 = WorkUnit.make(
          :ticket => ticket,
          :invoiced => 'invoiced on 2010-10-25' )
        uninvoiced_hours = work_unit_1.effective_hours + work_unit_2.effective_hours
        ticket.uninvoiced_hours.should == uninvoiced_hours
      end
    end
  end

  describe '.to_s' do
    it 'returns the name of the ticket as a string' do
      ticket = Ticket.make(:name => 'Testticket')
      ticket.to_s.should == 'Testticket'
    end
  end

  describe '.long_name' do
    it 'returns a descriptive string with the ticket id, project, and client' do
      ticket = Ticket.make
      id = ticket.id
      project_name = ticket.project.name
      client_name = ticket.project.client.name
      long_name = "Ticket: [#{id}] - #{project_name} Ticket for #{client_name}"
      ticket.long_name
    end
  end

  describe '.allows_access?' do
    before(:each) do
      @project = Project.make
      @ticket = Ticket.make(:project => @project)
      @user = User.make
    end

    it 'returns false if the user does not have access to the parent project' do
      @ticket.allows_access?(@user).should be_false
    end

    it 'returns true if the user has access to the parent project' do
      @user.has_role!(:developer, @project)
      @ticket.allows_access?(@user).should be_true
    end
  end

  describe '#for_user' do
    context 'when a user has access to a project' do
      it 'should return a collection of tickets for all the projects to which the user is assigned' do
        user = User.make
        project1 = Project.make
        user.has_role!(:developer, project1)
        project2 = Project.make
        ticket1 = Ticket.make(:project => project1)
        ticket2 = Ticket.make(:project => project1)
        ticket3 = Ticket.make(:project => project2)
        Ticket.for_user(user).include?(ticket1).should be_true
        Ticket.for_user(user).include?(ticket2).should be_true
        Ticket.for_user(user).include?(ticket3).should be_false
      end
    end
  end

  describe '.hours' do
    context 'when there are normal work units with hours' do
      it 'should return the correct sum of hours for those work units' do
        ticket1 = Ticket.make
        ticket2 = Ticket.make
        work_unit1 = WorkUnit.make(:ticket => ticket1, :hours => '1.0', :hours_type => 'Normal')
        work_unit2 = WorkUnit.make(:ticket => ticket1, :hours => '1.0', :hours_type => 'Normal')
        work_unit3 = WorkUnit.make(:ticket => ticket2, :hours => '1.0', :hours_type => 'Normal')
        ticket1.hours.should == 2.0
      end
    end
  end
end
