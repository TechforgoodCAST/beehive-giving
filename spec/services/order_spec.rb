require 'rails_helper'

describe Order do
  subject { Order.new('1999', '80') }

  it { expect(subject.amount).to eq(1999) }

  it { expect(subject.fee).to eq(80) }

  it { expect(subject.amount_to_currency).to eq('£19.99') }

  it { expect(subject.fee_to_currency).to eq('£0.80') }

  it { expect(subject.total).to eq(2079) }

  it { expect(subject.total_to_currency).to eq('£20.79') }
end
