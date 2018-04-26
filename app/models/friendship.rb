class Friendship < ApplicationRecord
  validate :equal
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :state, presence: true, inclusion: { in: ['accepted', 'pending', 'requested'] }
  validates :friend, uniqueness: { scope: :user }

  private

  def equal
    errors.add(:user, 'cannot friend itself') if user.equal?(friend)
  end
end
