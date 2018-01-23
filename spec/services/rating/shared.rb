RSpec.shared_examples 'incomplete' do
  it('#colour')  { expect(subject.colour).to eq('grey') }
  it('#message') { expect(subject.message).to eq(nil) }
  it('#status')  { expect(subject.status).to eq('-') }
end

RSpec.shared_examples 'ineligible' do
  it('#colour') { expect(subject.colour).to eq('red') }
  it('#status') { expect(subject.status).to eq('Ineligible') }
end

RSpec.shared_examples 'eligible' do
  it('#colour') { expect(subject.colour).to eq('green') }
  it('#status') { expect(subject.status).to eq('Eligible') }
end