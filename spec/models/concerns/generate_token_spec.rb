require 'rails_helper'

describe GenerateToken do
  subject do
    class Tokenable
      include GenerateToken
      attr_accessor :auth_token
    end
    Tokenable.new
  end

  it '#generates_token' do
    subject.generate_token(:auth_token)
    expect(subject.auth_token).not_to eq(nil)
    expect(subject.auth_token.size).to eq(22)
  end
end
