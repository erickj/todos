require 'todo/command'
require 'todo/view/mailer_view'

RSpec.describe Todo::View::MailerView do

  context 'on a create todo' do

    let(:todo) do
      Todo::Command::CreateTodo.build({
                                        :owner_email => 'e@j.com',
                                        :title => 'Send an email',
                                        :description => 'don\'t forget to send the mail'
                                      })
    end
  end
end
