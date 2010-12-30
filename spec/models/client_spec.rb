require 'spec_helper'

describe Client do
  let(:client) { Client.make(:name => 'New Client', :status => 'Active') }
  let(:project) { Project.make(:client => client)  }
  let(:ticket)  { Ticket.make(:project => project) }
  subject { client }

  it { should have_many :projects }
  it { should have_many(:tickets).through(:projects) }
  it { should have_many :comments }
  it { should have_many :file_attachments }
  it { should have_many :contacts }

  it { should validate_presence_of :name }
  it { should validate_presence_of :status }
  it { should validate_uniqueness_of :name }

  describe '.to_s' do
    subject { client.to_s }
    it 'returns the client name' do
      should == 'New Client'
    end
  end

  describe '.allows_access?' do
    subject { client.allows_access?(user) }
    let(:user) { User.make }
    let(:project) { Project.make(:client => client) }

    context 'when the user has access to one or more of its projects' do
      before { user.has_role!(:developer, project) }
      it { should be_true }
    end

    context 'when the user has access to none of its projects' do
      before { user.has_no_roles_for!(project) }
      it { should be_false }
    end
  end

  describe '.uninvoiced_hours' do
    subject { client.uninvoiced_hours }

    context 'when there are invoiced and uninvoiced work units' do
      before do
        work_unit1 = WorkUnit.make(:ticket => ticket, :hours => 1, :hours_type => 'Normal')
        work_unit2 = WorkUnit.make(:ticket => ticket, :hours => 1, :hours_type => 'Normal')
        work_unit3 = WorkUnit.make(:ticket => ticket, :hours => 1, :hours_type => 'Normal', :invoiced => '1111', :invoiced_at => Date.current )
      end

      it 'returns the sum of the hours on the uninvoiced work units' do
        should == 2
      end
    end
  end

  describe '.hours' do
    subject { client.hours }

    context 'when there are normal work units with hours' do
      before do
        work_unit1 = WorkUnit.make(:ticket => ticket, :hours => 1, :hours_type => 'Normal')
        work_unit2 = WorkUnit.make(:ticket => ticket, :hours => 1, :hours_type => 'Normal')
      end

      it 'should return the correct sum of hours for those work units' do
        should == 2
      end
    end
  end

  describe '.tickets' do
    subject { client.tickets }

    context 'when the client has tickets' do
      let(:ticket2) { Ticket.make(:project => project) }

      it 'returns the collection of tickets that belong to the client' do
        should == [ticket, ticket2]
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

  describe 'while being created' do
    it 'should create a new client from the blueprint' do
      lambda do
        Client.make
      end.should change(Client, :count).by(1)
    end
  end

end

