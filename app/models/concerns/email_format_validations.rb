module EmailFormatValidations
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true, format: {
      with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
      message: 'please enter a valid email'
    }
  end
end
