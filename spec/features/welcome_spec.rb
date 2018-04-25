require 'rails_helper'

RSpec.feature "Welcome", type: :feature do
  describe 'index' do
    context 'when a user is not logged in' do
      it 'displays the correct message' do
        visit '/'
        expect(page).to have_text('Sign up or log in to get started!')
      end
    end

    context 'when a user is logged in' do
      let!(:user1) { User.create(first_name: 'User', last_name: 'One', email: 'user1@test.com', password: 'test') }
      let!(:user2) { User.create(first_name: 'User', last_name: 'Two', email: 'user2@test.com', password: 'test') }
      let!(:user3) { User.create(first_name: 'User', last_name: 'Three', email: 'user3@test.com', password: 'test') }
      let!(:status1) { Status.create(user: user2, text: 'User 2 Status') }
      let!(:status2) { Status.create(user: user1, text: 'User 1 Status') }
      let!(:status3) { Status.create(user: user3, text: 'User 3 Status') }

      before(:each) do
        page.set_rack_session(user_id: user1.id)
        user1.send_friend_request(user2)
        user2.accept_friend_request(user1)
        visit '/'
      end

      it 'displays a form to create a status' do
        expect(page).to have_button('Create Status')
      end

      it 'only displays the statuses for friends and the current users' do
        expect(all('.card-text').count).to eq(2)
      end

      it 'lists the statuses in descending order' do
        expect(all('.card-text').first.text).to eq(status2.text)
        expect(all('.card-text').last.text).to eq(status1.text)
      end
    end
  end
end
