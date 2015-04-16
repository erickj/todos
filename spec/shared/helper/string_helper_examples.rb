shared_examples 'a string helper' do

  it 'truncates string' do
    expect(subject.truncate_string 'pneumonoultramicroscopicsilicovolcanoconiosis', 5)
      .to be == 'pneum...'
  end

  it 'truncates strings with custom eliding' do
    expect(subject.truncate_string 'pneumonoultramicroscopicsilicovolcanoconiosis', 5, '!')
      .to be == 'pneum!'
  end

end
