class SiteSettings < ActiveRecord::Base
  has_attached_file :site_logo, :default_url => '/public/images/logo.png'
end
