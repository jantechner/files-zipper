require 'securerandom'
require 'zip'

class FilesController < ApplicationController

  ZIPS_FOLDER = 'tmp/storage'

  def show
    redirect_to root_url unless flash.present?
  end

  def create
    password = SecureRandom.base64(16)
    filename = Time.now.to_i.to_s
    filepath = "#{ZIPS_FOLDER}/#{filename}.zip"

    # Zip::File.open(filename, Zip::File::CREATE) do |zip|
    #   params[:files].each do |file|
    #     zip.add(file.original_filename, file.tempfile)
    #   end
    # end

    buffer = Zip::OutputStream.write_buffer(::StringIO.new(''), Zip::TraditionalEncrypter.new(password)) do |out|
      params[:files].each do |file|
        out.put_next_entry file.original_filename
        out.write file.tempfile.read
      end
    end
    File.open(filepath, 'wb') {|f| f.write(buffer.string) }

    flash[:password] = password

    redirect_to action: 'show', id: filename
  end

  def download
    send_file(
      "#{Rails.root}/#{ZIPS_FOLDER}/#{params[:id]}.zip",
      type: 'application/zip'
    )
  end

end
