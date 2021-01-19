require 'rails_helper'

RSpec.describe "Files", type: :feature do

  it 'redirects to new form on root' do
    visit '/'
    expect(current_path).to eq('/zipper/new')
  end

  it 'shows a new form' do
    visit new_zipper_path
    expect(page).to have_field('files[]', type: :file)
  end

  it 'creates a zip file' do
    files = {}
    filenames = %w[a.txt b.txt]
    filenames.each do |filename|
      path = "#{Rails.root}/spec/fixtures/files/#{filename}"
      files[filename] = {
        path: path,
        content: File.read(path)
      }
    end

    visit new_zipper_path

    page.attach_file "files[]", files.map { |k, v| v[:path] }

    find('input[name=commit]').click

    file_id = page.current_url.split('/').last
    password = page.find_by_id('password').text
    expect(password.length).to eql(24)

    download_link = page.find_link
    expect(download_link[:href]).to eq("#{file_id}/download")
    expect(download_link.text).to eq("Download zip")

    download_link.click

    Zip::InputStream.open(StringIO.new(page.body), 0, Zip::TraditionalDecrypter.new(password)) do |io|
      while entry = io.get_next_entry
        expect(entry.encrypted?).to be_truthy
        expect(files.dig(entry.name, :content)).to eql(io.read)
      end
    end

  end
end
