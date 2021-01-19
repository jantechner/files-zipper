# frozen_string_literal: true

class FilesController < ApplicationController

  before_action :validate_params, only: :create

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

  private

  def validate_params
    begin
      params.require(:files)
    rescue
      redirect_to action: 'new'
    end
  end

end
