class Admin::SiteSettingsController < ApplicationController
  def edit
    @site_settings = SiteSettings.first
  end

  def update
    @site_settings = SiteSettings.first
    params[:admin_site_settings][:overtime_multiplier] = params[:admin_site_settings][:overtime_multiplier].to_d

    if @site_settings.update_attributes(params[:admin_site_settings])
      flash[:notice] = t(:site_settings_updated_successfully)
      redirect_to :back
    else
      flash[:error] = t(:site_settings_updated_unsuccessfully)
      redirect_to :back
    end
  end
end
