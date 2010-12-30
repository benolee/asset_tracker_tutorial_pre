require 'spec_helper'

describe Client do

  it { should have_many :projects }
  it { should have_many(:tickets).through(:projects) }
  it { should have_many :comments }
  it { should have_many :file_attachments }
  it { should have_many :contacts }

  it { should validate_presence_of :name }
  it { should validate_presence_of :status }

  it { Client.make; should validate_uniqueness_of :name }

  describe 'while being created' do
    it 'should create a new client from the blueprint' do
      lambda do
        Client.make
      end.should change(Client, :count).by(1)
    end
  end

  describe '.to_s' do
    it 'returns the client name as a string' do
      client = Client.make(:name => 'Testclient')
      client.to_s.should == 'Testclient'
    end
  end

  describe '.allows_access?' do
    before(:each) do
      @project = Project.make
      @client = @project.client
      @user = User.make
    end

    it 'returns false given a user that has no access to any of its projects' do
      @client.allows_access?(@user).should be_false
    end

    it 'returns true given a user has access to one or more of its projects' do
      @user.has_role!(:developer, @project)
      @client.allows_access?(@user).should be_true
    end
  end

  describe '.uninvoiced_hours' do
    it "returns the sum of hours on all the client's work units" do
      work_unit_1 = WorkUnit.make
      ticket = work_unit_1.ticket
      client = work_unit_1.client
      work_unit_2 = WorkUnit.make(:ticket => ticket)
      work_unit_3 = WorkUnit.make(:ticket => ticket, :invoiced => 'Invoiced', :invoiced_at => Time.current)
      total_hours = work_unit_1.effective_hours + work_unit_2.effective_hours
      client.uninvoiced_hours.should == total_hours
    end
  end

  describe '.hours' do
    context 'when there are normal work units with hours' do
      it 'should return the correct sum of hours for those work units' do
        work_unit1 = WorkUnit.make(:hours => '1.0', :hours_type => 'Normal')
        client1 = work_unit1.client
        work_unit2 = WorkUnit.make(:hours => '1.0', :hours_type => 'Normal', :ticket => work_unit1.ticket)
        work_unit3 = WorkUnit.make(:hours => '1.0', :hours_type => 'Normal')
        client1.hours.should == 2.0
      end
    end
  end

  describe '.tickets' do
    context 'when the client has tickets' do
      it 'returns the collection of tickets that belong to the client' do
        ticket1 = Ticket.make
        ticket2 = Ticket.make(:project => ticket1.project)
        ticket3 = Ticket.make
        client = ticket1.client
        client.tickets.include?(ticket1).should be_true
        client.tickets.include?(ticket2).should be_true
        client.tickets.include?(ticket3).should be_false
      end
    end
  end

  describe '.for_user' do
    context 'when a user has access to projects of clients' do
      it 'returns a collection of clients to which the user has access' do
        user = User.make
        client1 = Client.make
        project1 = Project.make(:client => client1)
        client2 = Client.make
        project2 = Project.make(:client => client2)
        user.has_role!(:developer, project1)
        user.has_no_roles_for!(project2)
        Client.for_user(user).include?(client1).should be_true
        Client.for_user(user).include?(client2).should be_false
      end
    end
  end

  describe '.for' do
    context 'given a collection of projects' do
      it 'returns a unique list of clients for those projects' do
        projects = [project1 = Project.make, project2 = Project.make]
        Client.for(projects).include?(project1.client).should be_true
        Client.for(projects).include?(project2.client).should be_true
      end
    end
    context 'given a collection of tickets' do
      it 'returns a unique list of clients for those tickets' do
        tickets = [ticket1 = Ticket.make, ticket2 = Ticket.make]
        Client.for(tickets).include?(ticket1.client).should be_true
        Client.for(tickets).include?(ticket2.client).should be_true
      end
    end
    context 'given a collection of work units' do
      it 'returns a unique list of clients for those work units' do
        work_units = [work_unit1 = WorkUnit.make, work_unit2 = WorkUnit.make]
        Client.for(work_units).include?(work_unit1.client).should be_true
        Client.for(work_units).include?(work_unit2.client).should be_true
      end
    end
  end
end

