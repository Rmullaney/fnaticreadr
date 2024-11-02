require 'rails_helper'

RSpec.describe "NewCreate", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "create a new book " do
    it 'successful create' do
      visit new_book_path
      fill_in 'Title', with: 'Test Book'
      fill_in 'Author', with: 'Test Description'
      select 'Fiction', from: 'Genre'
      fill_in 'Pages', with: 'Test Address'
      fill_in 'Description', with: '0123456789'
      fill_in 'Publisher', with: 'Test Publisher'
      # fill_in 'Publish date', with: 'Test Publisher' # FIX
      fill_in 'Isbn 13', with: '0101'
      fill_in 'Language written', with: 'Test language'
      # attach_file 'Images', "#{Rails.root}/spec/testimg.jpg"
      click_on 'Create Book'
      expect(page).to have_content('Book Test Book created successfully')
      expect(page.current_path).to eq(books_path)
      expect(page).to have_content('Test Book')
    end
    
    # it 'unsuccessful create' do
    #   s = Sight.new
    #   allow(Sight).to receive(:new).and_return(s)
    #   allow(s).to receive(:save).and_return(nil)
    #   visit new_sight_path
    #   click_on 'Create Sight'
    #   expect(page.current_path).to eq(sights_path) # assume no redirect, just render 'new'
    #   expect(page.text).to match(/Sight could not be created/)
    # end
  end
end