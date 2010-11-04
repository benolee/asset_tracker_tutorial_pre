class Dashboard::BaseController < ApplicationController
  respond_to :html, :json, :js

  def index

    if params[:date].present?
      @start_date = Date.parse(params[:date]).beginning_of_week
    else
      @start_date = Date.today.beginning_of_week
    end

    if current_user.work_units_for_day(Date.today.prev_working_day).empty?
      show_message("Management", "You have not entered any time for yesterday. Please Enter it immediatly!")
    end

    @clients = Client.all
    @projects ||= []
    @tickets  ||= []

  end

  def client
    @projects = Project.find(:all, :conditions => ['client_id = ?', params[:id]])
    respond_with @projects
  end

  def project
    @tickets = Ticket.find(:all, :conditions => ['project_id = ?', params[:id]])
    respond_with @tickets
  end

  protected
  def show_message(title, message)
    @show_message = "true" unless Rails.env.test?
    @title = title
    @message = message
  end

end
