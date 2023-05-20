class User < ActiveRecord::Base
  has_many :images, dependent: :destroy
  before_save :encrypt_password

  private

  def encrypt_password
    self.password = BCrypt::Password.create(password)
  end

  public

  def authenticate(password)
    BCrypt::Password.new(self.password) == password
  end

end