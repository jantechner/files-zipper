require 'securerandom'
require 'zip'

class FileZipper < ApplicationService

  ZIPS_FOLDER = 'tmp/storage'
  PASSWORD_LENGTH = 16

  def initialize(files)
    @files = files
    @filename = filename
    @password = password
  end

  def call
    filepath = "#{ZIPS_FOLDER}/#{@filename}.zip"

    buffer = Zip::OutputStream.write_buffer(::StringIO.new(''), Zip::TraditionalEncrypter.new(@password)) do |out|
      @files.each do |file|
        out.put_next_entry file.original_filename
        out.write file.tempfile.read
      end
    end

    File.open(filepath, 'wb') { |f| f.write(buffer.string) }

    [@filename, @password]
  end

  def self.get_filepath(id)
    "#{Rails.root}/#{ZIPS_FOLDER}/#{id}.zip"
  end

  private

  def filename
    DateTime.now.strftime("%Q") # timestamp with milliseconds
  end

  def password
    SecureRandom.alphanumeric(PASSWORD_LENGTH)
  end

end
