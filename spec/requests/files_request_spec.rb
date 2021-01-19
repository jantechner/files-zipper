require 'rails_helper'

RSpec.describe "zipping files", type: :feature do

  context 'when accessing the root path' do
    it 'redirects to new form' do
      visit '/'
      expect(current_path).to eq('/zipper/new')
    end
  end

  context 'when opening the form' do
    it 'shows a new form' do
      visit new_file_path
      expect(page).to have_field('files[]', type: :file)
    end
  end

  context 'when submitting valid files' do
    before do
      @files = sample_files
      visit new_file_path
      page.attach_file "files[]", @files.map { |k, v| v[:path] }
      find('input[name=commit]').click
      @file_id = page.current_url.split('/').last
    end

    it 'shows the proper link to a zip file' do
      download_link = page.find_link
      expect(download_link[:href]).to eq("#{@file_id}/download")
      expect(download_link.text).to eq("Download zip")
    end

    it 'show the password to the zip file' do
      password = page.find_by_id('password').text
      expect(password.length).to eql(FileZipper::PASSWORD_LENGTH)
    end

    describe 'downloading the zip file' do
      before do
        @password     = page.find_by_id('password').text
        download_link = page.find_link
        download_link.click
      end

      it 'downloads the file' do
        header = page.response_headers['Content-Disposition']

        expect(page.response_headers['Content-Type']).to eq "application/zip"
        expect(header).to match /^attachment/
        expect(header).to match /filename=\"#{@file_id}\.zip\"$/
      end

      it 'encodes the file properly' do
        Zip::InputStream.open(StringIO.new(page.body), 0, Zip::TraditionalDecrypter.new(@password)) do |io|
          while (entry = io.get_next_entry)
            expect(entry.encrypted?).to be_truthy
            expect(@files.dig(entry.name, :content)).to eql(io.read)
          end
        end
      end

      it 'allows to download the file again' do
        visit download_file_path(@file_id)

        header = page.response_headers['Content-Disposition']

        expect(page.response_headers['Content-Type']).to eq "application/zip"
        expect(header).to match /^attachment/
        expect(header).to match /filename=\"#{@file_id}\.zip\"$/
      end
    end

    it 'does not allow to display the password twice' do
      file_id = page.current_url.split('/').last

      visit file_path(id: file_id)

      expect(current_path).to eq('/zipper/new')
    end
  end

  context 'when submitting no files' do
    it 'redirects to the new form' do
      visit new_file_path
      page.attach_file "files[]", nil
      find('input[name=commit]').click

      expect(current_path).to eq('/zipper/new')
    end
  end

  private

  def sample_files
    files     = {}
    filenames = %w[a.txt b.txt]
    filenames.each do |filename|
      path            = "#{Rails.root}/spec/fixtures/files/#{filename}"
      files[filename] = {
        path:    path,
        content: File.read(path)
      }
    end
    files
  end
end
