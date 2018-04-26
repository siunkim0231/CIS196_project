require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let!(:user1) { User.create(first_name: 'User', last_name: 'One', email: 'user1@test.com') }
  let!(:user2) { User.create(first_name: 'User', last_name: 'Two', email: 'user2@test.com') }

  let!(:friendship1) { Friendship.create(user: user1, friend: user2, state: 'requested') }

  it 'belongs to to a user' do
    expect(friendship1.user).to eq(user1)
  end

  it 'belongs to a friend of class user' do
    expect(friendship1.friend).to eq(user2)
  end

  describe 'validations' do
    it 'is not valid without a state' do
      friendship = Friendship.new
      friendship.valid?
      expect(friendship.errors.messages[:state]).to include("can't be blank")
    end

    it "is not valid if the state is not 'accepted', 'pending', or 'requested'" do
      friendship = Friendship.new(state: 'declined')
      friendship.valid?
      expect(friendship.errors.messages[:state]).to include('is not included in the list')
    end

    it 'is not valid if the friend already exists for the user' do
      friendship = Friendship.new(user: user1, friend: user2, state: 'accepted')
      friendship.valid?
      expect(friendship.errors.messages[:friend]).to include('has already been taken')
    end

    it 'is not valid if the user and friend reference the same user' do
      friendship = Friendship.new(user: user1, friend: user1, state: 'accepted')
      friendship.valid?
      expect(friendship.errors.messages[:user]).to include('cannot friend itself')
    end

    it 'is valid with correct data' do
      expect(Friendship.new(user: user2, friend: user1, state: 'requested').valid?).to be true
      expect(Friendship.new(user: user2, friend: user1, state: 'pending').valid?).to be true
      expect(Friendship.new(user: user2, friend: user1, state: 'accepted').valid?).to be true
    end
  end
end
