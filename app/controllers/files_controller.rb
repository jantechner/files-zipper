require 'securerandom'
require 'zip'

class FilesController < ApplicationController

  def show
    redirect_to root_url unless flash.present?
  end

  def create
    password = new_password




    flash[:password] = password

    redirect_to action: 'show', id: filename
  end

  def download
    send_file(
      "#{Rails.root}/#{ZIPS_FOLDER}/#{params[:id]}.zip",
      type: 'application/zip'
    )
  end

  private

  def new_password
    SecureRandom.base64(16)
  end

  ZIPS_FOLDER = 'tmp/storage'

  def create_zip_file(files)
    filename = Time.now.to_i.to_s
    filepath = "#{ZIPS_FOLDER}/#{filename}.zip"

    buffer = Zip::OutputStream.write_buffer(::StringIO.new(''), Zip::TraditionalEncrypter.new(password)) do |out|
      params[:files].each do |file|
        out.put_next_entry file.original_filename
        out.write file.tempfile.read
      end
    end

    File.open(filepath, 'wb') {|f| f.write(buffer.string) }
  end

end
