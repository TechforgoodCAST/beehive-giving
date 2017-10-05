describe ApplicationContext do
  it 'requires #policy_class' do
    expect { ApplicationContext.policy_class }
      .to raise_error(NotImplementedError)
  end
end
