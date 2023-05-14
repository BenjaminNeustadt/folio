require_relative './spec_helper'
RSpec.describe User do
  describe '.create' do
    it 'creates a user with username, email, and password' do
      user = User.create(username: 'Donny', email: 'don@email.com', password: '1234')
      expect(user.username).to eq('Donny')
    end
  end
end