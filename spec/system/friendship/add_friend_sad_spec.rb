require 'rails_helper'

RSpec.describe "AddFriend", type: :system do
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :standard)
        @u3 = User.create!(first: "Charlie", last: "Chaplin", email: "cc@gmail.com", bio:"hey there", password:"cchaplin", role: :standard)
    end

    describe "add friend sad" do
        it "expect a friend to be unsuccessfully added" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "cc@gmail.com"
            fill_in 'Password', with: "cchaplin"
            click_on "Log in"
            expect(page).to have_content("Signed in successfully.")
            click_on "Social"
            expect(page).to have_content("Add Some Friends")
            expect(Friendship).to receive(:new).and_return(@u1)
            expect(@u1).to receive(:save).and_return(nil)
            click_on "#{@u1.first}"
            expect(page).to have_content("Friend could not be added")
            click_on "Social"
            expect(page).to have_content("Add Some Friends")
        end

        it "expect the friend unsuccessfully added to not have notfication with the senders name" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "cc@gmail.com"
            fill_in 'Password', with: "cchaplin"
            click_on "Log in"
            click_on "Social"
            expect(Friendship).to receive(:new).and_return(@u1)
            expect(@u1).to receive(:save).and_return(nil)
            click_on "#{@u1.first}"
            expect(page).to have_content("Friend could not be added")
            find('#profile_click').click
            click_on "Log Out"
            click_on "Log In"
            fill_in 'Email', with: "aa@gmail.com"
            fill_in 'Password', with: "aamerson"
            click_on "Log in"
            visit user_notifications_path(@u1)
            expect(page).not_to have_content("Charlie Chaplin")
        end
    end
end