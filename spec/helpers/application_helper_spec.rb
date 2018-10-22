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

  it '#obscure_email' do
    expect(subject.obscure_email('email@email.com')).to eq('em...@email.com')
  end

  context '#primary_color' do
    it 'default' do
      expect(subject.primary_color(nil)).to eq('#3B88F5')
    end

    it 'from collection' do
      collection = OpenStruct.new(primary_color: '#000')
      expect(subject.primary_color(collection)).to eq('#000')
    end
  end

  context '#secondary_color' do
    it 'default' do
      expect(subject.secondary_color(nil)).to eq('#1C4073')
    end

    it 'from collection' do
      collection = OpenStruct.new(secondary_color: '#FFF')
      expect(subject.secondary_color(collection)).to eq('#FFF')
    end
  end
end
