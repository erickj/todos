RSpec.describe Todo::Command::CreateTodo::ResultProcessor do

  let(:data) {{
                :owner_email => 'e@j.com',
                :title => 'a title',
                :description => 'a description',
                :collaborator_emails => [
                  'a@collab.com', 'b@collab.com'
                ]
              }}

  let(:command) { Todo::Command::CreateTodo::Command.build data }
  let(:processor) { Todo::Command::CreateTodo::Processor.new }
  let(:command_result) { processor.process_command command }
  let(:stub_adapter) { Todo::Mail::Adapter::Fake.new }

  subject { Todo::Command::CreateTodo::ResultProcessor.new }

  around(:each) do |example|
    default_adapter = Todo::Mail::Emailer.mail_adapter
    Todo::Mail::Emailer.mail_adapter stub_adapter

    example.run

    Todo::Mail::Emailer.mail_adapter default_adapter
  end

  it 'sends emails to the owner' do
    subject.process_command command_result

    owner_email = stub_adapter.email_info.first

    expect(owner_email[:to].map { |p| p[:email] }).to be == ['e@j.com']
    expect(owner_email[:body][:txt]).to be =~ /^Do Til Done/
    expect(owner_email[:body][:html]).to be =~ /^<!DOCTYPE html/
    expect(owner_email[:reply_to]).to be =~ /^todo\+[\S]+/
    expect(owner_email[:subject]).to be == 'Todo: [%s]' % data[:title]
  end

  it 'sends an emai to each collaborator' do
    subject.process_command command_result

    expect(stub_adapter.email_info.size).to be 3

    collaborator_emails = stub_adapter.email_info.slice(-2, 2)
    expect(collaborator_emails.map { |e| e[:to].map { |p| p[:email]} }.flatten)
      .to be == [ 'a@collab.com', 'b@collab.com']
    collaborator_emails.each do |e|
      expect(e[:body][:txt]).to be =~ /^Do Til Done/
      expect(e[:body][:html]).to be =~ /^<!DOCTYPE html/
      expect(e[:reply_to]).to be =~ /^todo\+[\S]+/
      expect(e[:subject]).to be == 'Todo: [%s]' % data[:title]
    end
  end

  context 'renders', :render do
    let(:description) do
      <<EOS
<script type="text/javascript">alert('pwnd')</script>

Let me take you down, cos I'm going to Strawberry Fields
Nothing is real and nothing to get hung about
Strawberry Fields forever

Living is easy with eyes closed
Misunderstanding all you see
It's getting hard to be someone but it all works out
It doesn't matter much to me
Let me take you down, cos I'm going to Strawberry Fields
Nothing is real and nothing to get hung about
Strawberry Fields forever
EOS
    end

    let(:data) {{
                  :owner_email => 'john@lennon.org',
                  :title => 'Strawberry Fields Forever',
                  :description => description,
                  :collaborator_emails => [
                    'paul@mccartney.org', 'ringo@star.com', 'george@harrison.net'
                  ]
                }}

    before(:each) { subject.process_command command_result }
    let(:owner_email_html) { stub_adapter.email_info.first[:body][:html] }
    let(:collab_email_html) { stub_adapter.email_info.last[:body][:html] }

    context 'emails' do

      it { save_rendered_data 'todo_create.email', 'owner.html', owner_email_html }
      it { save_rendered_data 'todo_create.email', 'collab.html', collab_email_html }

    end
  end
end
