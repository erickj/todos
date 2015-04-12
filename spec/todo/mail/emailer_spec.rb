require 'todo/mail/emailer'

RSpec.describe Todo::Mail::Emailer, :mail do

  let(:stub_adapter) { Todo::Mail::Adapter::Fake.new }

  class View
    def initialize(render_results={})
      @render_results = render_results
    end

    def render(type)
      @render_results[type]
    end
  end

  around(:each) do |example|
    default_adapter = Todo::Mail::Emailer.mail_adapter
    Todo::Mail::Emailer.mail_adapter stub_adapter

    example.run

    Todo::Mail::Emailer.mail_adapter default_adapter
  end

  context '#email_builder' do

    include Todo::Mail::Emailer

    it 'sets the subject' do
      email_builder.subject('a subject line').send
      expect(stub_adapter.email_info[:subject]).to eql 'a subject line'
    end

    it 'sets the reply_to' do
      email_builder.reply_to('foo@bar.com').send
      expect(stub_adapter.email_info[:reply_to]).to eql 'foo@bar.com'
    end

    it 'sets the to' do
      email_builder.to('foo@bar.com', 'bar@foo.com').send
      expect(stub_adapter.email_info[:to]).to eql ['foo@bar.com', 'bar@foo.com']
    end

    it 'sets the body' do
      email_builder.body(View.new :txt => 'a txt body', :html => '<html>body</html>').send
      expect(stub_adapter.email_info[:body][:txt]).to eql 'a txt body'
      expect(stub_adapter.email_info[:body][:html]).to eql '<html>body</html>'
    end
  end
end
