class FileAttachmentsController < ApplicationController
  before_filter :load_new_file_attachment, :only => [:new]
  before_filter :load_file_attachment, :only => [:show]
  before_filter :get_referrer, :only => [:create]

  protected

  def load_new_file_attachment
    @file_attachment = FileAttachment.new(params[:file_attachment])
    if params[:ticket_id]
      @file_attachment.ticket_id = params[:ticket_id]
    end
    if params[:client_id]
      @file_attachment.client_id = params[:client_id]
    end
    if params[:project_id]
      @file_attachment.project_id = params[:project_id]
    end
  end

  def load_file_attachment
    @file_attachment = FileAttachment.find(params[:id])
  end

  def get_referrer
    @referrer_path = case
    when params[:client_id]  then client_path params[:client_id]
    when params[:project_id] then project_path params[:project_id]
    when params[:ticket_id]  then ticket_path params[:ticket_id]
    else                          root_path
    end
  end

  public
  def show
    send_file(@file_attachment.attachment_file.path, :disposition => 'attachment')
  end

  def new
  end

  def create

    file = params[:file_attachment][:attachment_file].tempfile
    sha = Digest::SHA1.hexdigest(file.read)
    @file_attachment = FileAttachment.new(params[:file_attachment] )
    @file_attachment.sha = sha

    if params[:ticket_id]
      @file_attachment.ticket_id = params[:ticket_id]
    end
    if params[:client_id]
      @file_attachment.client_id = params[:client_id]
    end
    if params[:project_id]
      @file_attachment.project_id = params[:project_id]
    end

    if @file_attachment.save
      flash[:notice] = t(:file_attachment_created_successfully)
      redirect_to @referrer_path
    else
      flash.now[:error] = t(:file_attachment_created_unsuccessfully)
      render :action => :new
    end
  end
end
