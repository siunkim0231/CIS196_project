require 'rails_helper'

RSpec.feature "Users", type: :feature do
  let!(:user) { User.create(first_name: 'User', last_name: 'One', email: 'user1@test.com', password: 'test') }

  describe 'index' do
    context 'when no user is logged in' do
      it 'does not redirect' do
        visit '/users'
        expect(current_path).to eq('/users')
      end
    end

    context 'when there is a user logged in' do
      it 'does not redirect' do
        page.set_rack_session(user_id: user.id)
        visit '/users'
        expect(current_path).to eq('/users')
      end
    end
  end

  describe 'show' do
    context 'when no user is logged in' do
      it 'does not redirect' do
        visit "/users/#{user.id}"
        expect(current_path).to eq("/users/#{user.id}")
      end
    end

    context 'when there is a user logged in' do
      it 'does not redirect' do
        page.set_rack_session(user_id: user.id)
        visit "/users/#{user.id}"
        expect(current_path).to eq("/users/#{user.id}")
      end
    end
  end

  describe 'new' do
    context 'when no user is logged in' do
      it 'does not redirect' do
        visit '/users/new'
        expect(current_path).to eq('/users/new')
      end
    end

    context 'when there is a user logged in' do
      it 'does not redirect' do
        page.set_rack_session(user_id: user.id)
        visit '/users/new'
        expect(current_path).to eq('/users/new')
      end
    end
  end

  describe 'edit' do
    context 'when no user is logged in' do
      it 'redirects to the rot path' do
        visit "/users/#{user.id}/edit"
        expect(current_path).to eq('/')
      end
    end

    context 'when there is a user logged in' do
      it 'does not redirect' do
        page.set_rack_session(user_id: user.id)
        visit "/users/#{user.id}/edit"
        expect(current_path).to eq("/users/#{user.id}/edit")
      end
    end
  end

  describe 'friend_requests' do
    context 'when no user is logged in' do
      it 'redirects to the rot path' do
        visit '/friend_requests'
        expect(current_path).to eq('/')
      end
    end

    context 'when there is a user logged in' do
      it 'does not redirect' do
        page.set_rack_session(user_id: user.id)
        visit '/friend_requests'
        expect(current_path).to eq('/friend_requests')
      end
    end
  end

  describe 'create' do
    it 'logs the user in if a user was created successfully' do
      visit '/users/new'
      fill_in 'user_first_name', with: 'User'
      fill_in 'user_last_name', with: 'Two'
      fill_in 'user_email', with: 'user2@test.com'
      fill_in 'user_password', with: 'test'
      click_button 'Create User'
      expect(page.get_rack_session).to include('user_id')
    end
  end

  describe 'update' do
    it 'logs the user in if a user was created successfully' do
      page.set_rack_session(user_id: user.id)
      visit "/users/#{user.id}/edit"
      click_button 'Update User'
      expect(page.get_rack_session_key('user_id')).to eq(user.id)
    end
  end

  describe 'destroy' do
    it 'logs the user out' do
      page.set_rack_session(user_id: user.id)
      visit "/users/#{user.id}"
      click_link 'Delete Account'
      expect(page.get_rack_session[:user_id]).to be_nil
    end
  end
end
