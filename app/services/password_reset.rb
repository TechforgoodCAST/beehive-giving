class PasswordReset
  include ActiveModel::Model

  attr_accessor :email, :password, :password_confirmation

  validates :email, presence: true, on: :create
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
                              message: 'please enter a valid email' },
                    on: :create

  validates :password, :password_confirmation, presence: true, on: :update
  validates :password, length: { within: 6..25 }, confirmation: true,
                       on: :update
  validates :password,
            format: { with: /\A(?=.*\d)(?=.*[a-zA-Z]).{6,25}\z/,
                      message: 'Must include 6 characters with 1 number' },
            on: :update
end
