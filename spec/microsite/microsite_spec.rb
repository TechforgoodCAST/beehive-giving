require 'rails_helper'

describe Microsite do
  it '#initialize' do
    expect { subject }.to raise_error ArgumentError
  end

  it '#initialize step must respond to save' do
    step = Struct.new(:fields)
    expect { Microsite.new(step.new) }.to raise_error NotImplementedError
  end

  it '#step returns passed in object' do
    step = Struct.new(:fields) { def save; end }
    step_instance = step.new

    expect(Microsite.new(step_instance).step).to eq step_instance
  end

  it '#save calls passed in object' do
    step = Struct.new(:fields) do
      def save
        'save on step'
      end
    end

    expect(Microsite.new(step.new).save).to eq 'save on step'
  end
end
