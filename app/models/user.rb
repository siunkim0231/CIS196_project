require 'bcrypt'

class User < ApplicationRecord
  include BCrypt
  validate :fn
  validate :ln
  validate :em
  has_many :statuses, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, -> { where(friendships: { state: 'accepted' }) }, through: :friendships
  has_many :requested_friends, -> { where(friendships: { state: 'requested' }) }, through: :friendships, source: :friend
  has_many :pending_friends, -> { where(friendships: { state: 'pending' }) }, through: :friendships, source: :friend

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true

  def full_name
    first_name + ' ' + last_name
  end

  def send_friend_request(friend)
    return if Friendship.exists?(user: self, friend: friend) || Friendship.exists?(user: friend, friend: self)
    @friendship_req = Friendship.create(user: self, friend: friend, state: 'requested')
    @friendship_pend = Friendship.create(user: friend, friend: self, state: 'pending')
  end

  def accept_friend_request(friend)
    return unless Friendship.exists?(user: friend, friend: self, state: 'requested') && Friendship.exists?(user: self, friend: friend, state: 'pending')
    @from = Friendship.find_by(user: friend, friend: self, state: 'requested')
    @to = Friendship.find_by(user: self, friend: friend, state: 'pending')
    @from = Friendship.update(user: friend, friend: self, state: 'accepted')
    @to = Friendship.update(user: self, friend: friend, state: 'accepted')
  end

  def delete_friend(friend)
    Friendship.find_by(user: self, friend: friend).destroy if Friendship.exists?(user: self, friend: friend)
    Friendship.find_by(user: friend, friend: self).destroy if Friendship.exists?(user: friend, friend: self)
  end

  def password
    @password ||= Password.new(password_hash) unless password_hash.nil?
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  private

  def fn
    errors.add(:first_name, 'must be capitalized') if !first_name.nil? && first_name.capitalize != first_name
  end

  def ln
    errors.add(:last_name, 'must be capitalized') if !last_name.nil? && last_name.capitalize != last_name
  end

  def em
    errors.add(:email, "must have an '@' and a '.'") if !email.nil? && !email.include?('@')
    errors.add(:email, "must have an '@' and a '.'") if !email.nil? && !email.include?('.')
  end
end
