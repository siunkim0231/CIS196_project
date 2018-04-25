require 'rails_helper'

RSpec.feature "Sessions", type: :feature do
  let!(:user) { User.create(first_name: 'User', last_name: 'One', email: 'user1@test.com', password: 'test') }

  describe 'new' do
    it 'displays the correct form' do
      visit '/login'
      expect(page).to have_field('email')
      expect(page).to have_field('password')
    end
  end

  describe 'create' do
    before(:each) do
      visit '/login'
    end

    it 'redirects back to the login page if no data is entered' do
      click_button 'Log in'
      expect(current_path).to eq('/login')
    end

    it 'redirects back to the login page if user with email does not exist' do
      fill_in 'email', with: 'test@email.com'
      fill_in 'password', with: 'password'
      click_button 'Log in'
      expect(current_path).to eq('/login')
    end

    it 'does not log the user in with incorrect password' do
      fill_in 'email', with: 'user1@test.com'
      fill_in 'password', with: 'password'
      click_button 'Log in'
      expect(page.get_rack_session[:user_id]).to be_nil
    end

    it 'redirects back to the login page if incorrect password is entered' do
      fill_in 'email', with: 'user1@test.com'
      fill_in 'password', with: 'password'
      click_button 'Log in'
      expect(current_path).to eq('/login')
    end

    it 'logs the user in with correct password' do
      fill_in 'email', with: 'user1@test.com'
      fill_in 'password', with: 'test'
      click_button 'Log in'
      expect(page.get_rack_session_key('user_id')).to eq(user.id)
    end

    it 'redirects to the root page if correct password is entered' do
      fill_in 'email', with: 'user1@test.com'
      fill_in 'password', with: 'test'
      click_button 'Log in'
      expect(current_path).to eq('/')
    end
  end

  describe 'destroy' do
    before(:each) do
      page.set_rack_session(user_id: user.id)
      visit '/login'
      click_link 'Log out'
    end

    it 'logs the user out' do
      expect(page.get_rack_session[:user_id]).to be_nil
    end

    it 'redirects to the root page' do
      expect(current_path).to eq('/')
    end
  end
end
