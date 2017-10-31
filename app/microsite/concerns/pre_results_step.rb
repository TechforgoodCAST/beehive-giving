class PreResultsStep
  include ActiveModel::Model

  attr_accessor :assessment, :email

  validates :email, presence: true, format: {
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  }

  def save
    if valid?
      save_assessment! if save_user!
    else
      false
    end
  end

  private

    def save_user!
      user = User.where(email: email).first_or_initialize
      user.organisation = assessment&.recipient
      user.save(validate: false)
    end

    def save_assessment!
      return false unless assessment
      assessment.update(
        state: 'results',
        access_token: SecureRandom.urlsafe_base64
      )
    end
end
