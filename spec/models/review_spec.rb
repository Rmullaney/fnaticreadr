require 'rails_helper'

RSpec.describe Review, type: :model do
  before(:each) do
    @u1 = User.create!(first: "Allie", last: "Amberson", 
                email: "aa@gmail.com", bio:"wassup", 
                password:"aamerson", role: :admin)
    @b1 = FactoryBot.create(:book, genre: "fiction")
    # @b1 = Book.create!(title: "test", author: "test",
    #             genre: :fiction,
    #             pages: 100, description: "test",
    #             publisher: "test",
    #             publish_date: Date.new(2002, 2, 2), isbn_13: 1111111111111, language_written: "test")
  end
  
  
  describe "model attributes" do
    it "should respond to required attribute methods" do
      s = Review.new
      expect(s).to respond_to(:user_id)
      expect(s).to respond_to(:book_id)
      expect(s).to respond_to(:rating)
      expect(s).to respond_to(:review_text)
    end

    it "should allow creation of model objects with all attributes" do
      r = Review.new(user: @u1, book: @b1, rating: 4, review_text: 'test 1') 
      expect(r.save!).to be true
      expect(Review.all.count).to eq(1)
    end
  end

  describe "validations" do
    it "should require a user" do
      r = Review.new(book: @b1, rating: 4, review_text: 'test 1')
      expect(r).to be_invalid
      expect(r.save).to be false
    end

    it "should require an book" do
      r = Review.new(user: @u1, rating: 4, review_text: 'test 1')
      expect(r).to be_invalid
      expect(r.save).to be false
    end

    it "should require a rating" do
      r = Review.new(user: @u1, book: @b1, review_text: 'test 1')
      expect(r).to be_invalid
      expect(r.save).to be false
    end

    it "should require review text" do
      r = Review.new(user: @u1, book: @b1, rating: 4)
      expect(r).to be_invalid
      expect(r.save).to be false
    end
  end
end
