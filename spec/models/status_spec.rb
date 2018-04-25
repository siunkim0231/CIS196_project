require 'rails_helper'

RSpec.describe Status, type: :model do
  let!(:user) { User.create(first_name: 'User', last_name: 'One', email: 'user1@test.com') }

  it 'belongs to a user' do
    status = Status.create(text: 'Status', user: user)
    expect(status.user).to eq(user)
  end

  describe 'validations' do
    it 'is not valid without text' do
      status = Status.new
      status.valid?
      expect(status.errors.messages[:text]).to include("can't be blank")
    end

    it 'is not valid if the text is less than 5 characters' do
      status = Status.new(text: 'Text')
      status.valid?
      expect(status.errors.messages[:text]).to include('is too short (minimum is 5 characters)')
    end

    it 'is valid with correct data' do
      status = Status.new(user: user, text: 'Long enough')
      expect(status.valid?).to be true
    end
  end
end
