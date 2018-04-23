require 'rails_helper'

describe ApplicationHelper do
  class ApplicationHelperClass
    include ApplicationHelper

    attr_accessor :session

    def initialize(session)
      @session = session
    end
  end

  subject { ApplicationHelperClass.new(session) }

  let(:session) { {} }

  %i[functional_cookies performance_cookies].each do |key|
    context "#allow_#{key}?" do
      it('nil') { expect(subject.send("allow_#{key}?")).to eq(true) }

      it 'false' do
        session[key] = false
        expect(subject.send("allow_#{key}?")).to eq(false)
      end

      it 'true' do
        session[key] = true
        expect(subject.send("allow_#{key}?")).to eq(true)
      end

      it 'parses empty string' do
        session[key] = ''
        expect(subject.send("allow_#{key}?")).to eq(true)
      end

      it 'parses "false" string' do
        session[key] = 'false'
        expect(subject.send("allow_#{key}?")).to eq(false)
      end

      it 'parses "true" string' do
        session[key] = 'true'
        expect(subject.send("allow_#{key}?")).to eq(true)
      end
    end
  end
end
