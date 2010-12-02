class Admin::UnenteredTimeReportController < ApplicationController

  def index
    redirect_unless_monday('/admin/unentered_time_report/', params[:id])
  end

  def show
    redirect_unless_monday('/admin/unentered_time_report/', params[:id])
    @week_dates = build_week_hash_for(Date.parse(params[:id]))
    @users = User.select{|u| u.has_role?(:developer) && !u.locked }
  end

end
