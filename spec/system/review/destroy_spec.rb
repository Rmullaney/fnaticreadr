require 'rails_helper'

RSpec.describe "Show route", type: :system do
  before do
    driven_by(:rack_test)
  end
  
  before(:each) do
    @u1 = User.create!(first: "Allie", last: "Amberson", 
                email: "aa@gmail.com", bio:"wassup", 
                password:"aamerson", role: :admin)
    sign_in @u1

    @b1 = FactoryBot.create(:book)
    @r1 = FactoryBot.create(:review, book_id: @b1.id, user_id: @u1.id)
  end

  describe "destroying a review" do
    it 'deletes a review' do
      expect(Review.all.count).to eq(1)

      visit review_path(@r1)
      expect(page).to have_content(@r1.review_text)
      click_on 'Delete'
      expect(page).to have_content('Review deleted successfully')
      expect(page).not_to have_content(@r1.review_text)
      expect(Review.all.count).to eq(0)
    end

    describe 'handles failed delete' do
      it 'due to db error' do
        r = Review.create!(user: @u1, book: @b1, review_text: 'test 1', rating: 3)
        allow_any_instance_of(Review).to receive(:destroy).and_raise(StandardError)
  
        visit review_path(r)
        click_on 'Delete'
        expect(page.current_path).to eq(review_path(r))
        expect(page).to have_content('Error deleting review')
      end

      it 'due to invalid id' do
        r = Review.create!(user: @u1, book: @b1, review_text: 'test 1', rating: 3)
        allow_any_instance_of(Review).to receive(:destroy).and_raise(StandardError)

        visit review_path(r)
        click_on 'Delete'
        expect(page.current_path).to eq(review_path(r))
        expect(page).to have_content('Error deleting review')
      end
    end
  end
end