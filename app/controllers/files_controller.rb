class FilesController < ApplicationController

  def show
    redirect_to root_url unless flash.present?
  end

  def create
    file_id, file_password = FileZipper.call(params[:files])

    flash[:password] = file_password

    redirect_to action: 'show', id: file_id
  end

  def download
    filepath = FileZipper.get_filepath(params[:id])
    send_file(filepath, type: 'application/zip')
  end

end
