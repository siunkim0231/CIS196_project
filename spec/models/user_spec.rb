require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user1) { User.create(first_name: 'User', last_name: 'One', email: 'user1@test.com') }
  let!(:user2) { User.create(first_name: 'User', last_name: 'Two', email: 'user2@test.com') }
  let!(:user3) { User.create(first_name: 'User', last_name: 'Three', email: 'user3@test.com') }
  let!(:user4) { User.create(first_name: 'User', last_name: 'Four', email: 'user4@test.com') }

  describe 'statuses' do
    let!(:status) { Status.create(text: 'Status', user: user1) }

    it 'has many statuses' do
      expect(user1.statuses).to include(status)
    end

    it 'destroys associated statuses when destroyed' do
      expect { user1.destroy }.to change { Status.count }.by(-1)
    end
  end

  describe 'friendships' do
    let!(:friendship1) { Friendship.create(user: user1, friend: user2, state: 'pending') }
    let!(:friendship2) { Friendship.create(user: user1, friend: user3, state: 'accepted') }
    let!(:friendship3) { Friendship.create(user: user1, friend: user4, state: 'requested') }

    it 'has many friendships' do
      expect(user1.friendships).to include(friendship1, friendship2)
    end

    it 'destroys associated friendships when destroyed' do
      expect { user1.destroy }.to change { Friendship.count }.by(-3)
    end

    it 'has many friends' do
      expect(user1.friends).to match_array([user3])
    end

    it 'has many requested_friends' do
      expect(user1.requested_friends).to match_array([user4])
    end

    it 'has many pending_friends' do
      expect(user1.pending_friends).to match_array([user2])
    end
  end

  describe 'BCrypt' do
    it 'includes BCrypt' do
      expect(User.ancestors).to include(BCrypt)
    end

    it 'has a #password method' do
      expect(User.public_instance_methods).to include(:password)
    end

    it 'has a #password= method' do
      expect(User.public_instance_methods).to include(:password=)
    end

    it 'does not have a password column' do
      expect(ApplicationRecord.connection.column_exists?(:users, :password)).to be false
    end

    it 'does have a password_hash column' do
      expect(ApplicationRecord.connection.column_exists?(:users, :password_hash)).to be true
    end
  end

  it "returns the user's full name" do
    expect(user1.full_name).to eq("#{user1.first_name} #{user1.last_name}")
  end

  describe 'validations' do
    it 'is not valid without a first_name' do
      user = User.new
      user.valid?
      expect(user.errors.messages[:first_name]).to include("can't be blank")
    end

    it 'is not valid without a last_name' do
      user = User.new
      user.valid?
      expect(user.errors.messages[:last_name]).to include("can't be blank")
    end

    it 'is not valid without an email' do
      user = User.new
      user.valid?
      expect(user.errors.messages[:email]).to include("can't be blank")
    end

    it 'is not valid with a duplicate email' do
      user = User.new(email: 'user1@test.com')
      user.valid?
      expect(user.errors.messages[:email]).to include('has already been taken')
    end

    it 'is not valid with a non-capitalized first_name' do
      user = User.new(first_name: 'user')
      user.valid?
      expect(user.errors.messages[:first_name]).to include('must be capitalized')
    end

    it 'is not valid with a non-capitalized last_name' do
      user = User.new(last_name: 'five')
      user.valid?
      expect(user.errors.messages[:last_name]).to include('must be capitalized')
    end

    it "is not valid if the email does not have an '@'" do
      user = User.new(email: '.')
      user.valid?
      expect(user.errors.messages[:email]).to include("must have an '@' and a '.'")
    end

    it "is not valid if the email does not have a '.'" do
      user = User.new(email: '@')
      user.valid?
      expect(user.errors.messages[:email]).to include("must have an '@' and a '.'")
    end

    it "is not valid if the email does not have an '@' and a '.'" do
      user = User.new(email: 'email')
      user.valid?
      expect(user.errors.messages[:email]).to include("must have an '@' and a '.'")
    end

    it 'is valid with correct data' do
      expect(User.new(first_name: 'User', last_name: 'Five', email: 'user5@test.com').valid?).to be true
    end
  end

  describe 'friend methods' do
    describe '#send_friend_request' do
      it 'does not create a friendship if it already exists' do
        Friendship.create(user: user1, friend: user2, state: 'accepted')
        Friendship.create(user: user2, friend: user1, state: 'accepted')
        expect { user1.send_friend_request(user2) }.to_not change { Friendship.count }
      end

      it 'creates two friendships' do
        expect { user1.send_friend_request(user2) }.to change { Friendship.count }.by(2)
      end

      it "creates a friendship from the user with state 'requested'" do
        user1.send_friend_request(user2)
        expect(Friendship.exists?(user: user1, friend: user2, state: 'requested')).to be true
      end

      it "creates a friendship to the user with the state 'pending'" do
        user1.send_friend_request(user2)
        expect(Friendship.exists?(user: user2, friend: user1, state: 'pending')).to be true
      end
    end

    describe '#accept_friend_request' do
      it "does not update the friendship if incoming friendship does not exist" do
        friendship = Friendship.create(user: user1, friend: user2, state: 'pending')
        expect { user1.accept_friend_request(user2) }.to_not change { friendship.state }
      end

      it "does not update the friendship if outgoing friendship does not exist" do
        friendship = Friendship.create(user: user2, friend: user1, state: 'requested')
        expect { user1.accept_friend_request(user2) }.to_not change { friendship.state }
      end

      it 'updates the incoming friendship' do
        Friendship.create(user: user1, friend: user2, state: 'pending')
        Friendship.create(user: user2, friend: user1, state: 'requested')
        user1.accept_friend_request(user2)
        expect(Friendship.exists?(user: user1, friend: user2, state: 'accepted')).to be true
        expect(Friendship.exists?(user: user2, friend: user1, state: 'accepted')).to be true
      end
    end

    describe '#delete_friend' do
      it 'destroys accepted friendships' do
        Friendship.create(user: user1, friend: user2, state: 'accepted')
        Friendship.create(user: user2, friend: user1, state: 'accepted')
        expect { user1.delete_friend(user2) }.to change { Friendship.count }.by(-2)
      end

      it 'destroys pending/requested friendships' do
        Friendship.create(user: user1, friend: user2, state: 'pending')
        Friendship.create(user: user2, friend: user1, state: 'requested')
        expect { user1.delete_friend(user2) }.to change { Friendship.count }.by(-2)
      end

      it 'destroys a friendship even if it is one-sided' do
        Friendship.create(user: user2, friend: user1, state: 'accepted')
        expect { user1.delete_friend(user2) }.to change { Friendship.count }.by(-1)
      end

      it 'does not destroy anything if friendships do not exist' do
        expect { user1.delete_friend(user2) }.to_not change { Friendship.count }
      end
    end
  end
end
