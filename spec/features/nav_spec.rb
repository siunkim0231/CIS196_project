require 'rails_helper'

RSpec.feature "Nav", type: :feature do
  let!(:user) { User.create(first_name: 'User', last_name: 'One', email: 'user1@test.com', password: 'test') }

  context 'when no user is logged in' do
    before(:each) do
      visit '/'
    end

    it 'displays link to all users' do
      expect(page).to have_link('Users', href: '/users')
    end

    it 'displays Log in and Sign up links' do
      expect(page).to have_link('Log in', href: '/login')
      expect(page).to have_link('Sign up', href: '/users/new')
    end

    it "does not display the user's name, Friend Requests, or Log out link" do
      expect(page).to_not have_link(user.full_name)
      expect(page).to_not have_link('Friend Requests')
      expect(page).to_not have_link('Log out')
    end
  end

  context 'when a user is logged in' do
    before(:each) do
      page.set_rack_session(user_id: user.id)
      visit '/'
    end

    it "display's the user's name, Friend Request, and Log out links" do
      expect(page).to have_link(user.full_name, href: "/users/#{user.id}")
      expect(page).to have_link('Friend Requests', href: '/friend_requests')
      expect(page).to have_link('Log out', href: '/logout')
    end

    it 'does not display Log in and Sign up links' do
      expect(page).to_not have_link('Log in')
      expect(page).to_not have_link('Sign up')
    end
  end
end
