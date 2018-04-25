require 'rails_helper'

RSpec.feature "Statuses", type: :feature do
  let!(:user) { User.create(first_name: 'User', last_name: 'One', email: 'user1@test.com', password: 'test') }
  let!(:status) { Status.create(user: user, text: 'This is a status') }

  describe 'new' do
    context 'when no user is logged in' do
      it 'redirects to the root path' do
        visit '/statuses/new'
        expect(current_path).to eq('/')
      end
    end

    context 'when there is a user logged in' do
      it 'does not redirect the user' do
        page.set_rack_session(user_id: user.id)
        visit '/statuses/new'
        expect(current_path).to eq('/statuses/new')
      end
    end
  end

  describe 'edit' do

    context 'when no user is logged in' do
      it 'redirects to the root path' do
        visit "/statuses/#{status.id}/edit"
        expect(current_path).to eq('/')
      end
    end

    context 'when there is a user logged in' do
      it 'does not redirect the user' do
        page.set_rack_session(user_id: user.id)
        visit "/statuses/#{status.id}/edit"
        expect(current_path).to eq("/statuses/#{status.id}/edit")
      end
    end
  end
end
