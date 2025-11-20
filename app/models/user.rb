class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :x_interest

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def x_interest!
    x_interest || create_x_interest!
  end
end
