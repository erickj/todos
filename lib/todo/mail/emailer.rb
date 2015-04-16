require 'mandrill'

module Todo
  module Mail
    module Emailer

      class << self
        def mail_adapter(adapter=nil)
          @mail_adapter ||= Adapter::Mandril.new
          if adapter
            @mail_adapter = adapter
          end
          @mail_adapter
        end
      end

      def email_builder
        EmailBuilder.new Todo::Mail::Emailer.mail_adapter
      end

      class EmailBuilder
        include Logging

        def initialize(mail_adapter)
          @mail_adapter = mail_adapter
        end

        def subject(subject)
          @subject = subject
          self
        end

        def reply_to(username)
          @reply_to = username
          self
        end

        def to(*persons)
          @to = persons.map do |p|
            if p.respond_to?(:email) && p.respond_to?(:name)
              { :email => p.email, :name => p.name }
            else
              raise 'invalid person type for email' unless p.is_a? String
              { :email => p, :name => p }
            end
          end
          self
        end

        def body_txt(body_txt)
          @body_txt = body_txt
          self
        end

        def body_html(body_html)
          @body_html = body_html
          self
        end

        def send
          raise 'missing To address' unless @to
          @mail_adapter.send_mail({
                              :subject => @subject,
                              :to => @to,
                              :reply_to => @reply_to,
                              :body => {
                                :html => @body_html,
                                :txt => @body_txt
                              }
                            })
          log.info { 'sent email to %s' % @to.map { |p| p[:email] } }
        end
      end
    end

    module Adapter

      class Fake
        attr_reader :email_info

        def send_mail(email_info)
          @email_info ||= []
          @email_info << email_info
        end
      end

      class Mandril
        def send_mail(email_info)
          m = Mandrill::API.new
          message = {
            :subject => email_info[:subject],
            :text => email_info[:body][:txt],
            :html => email_info[:body][:html],
            :from_name => ENV['FROM_NAME'],
            :from_email => ENV['FROM_EMAIL'],
            :to => email_info[:to].map do |p|
              if ENV['OVERRIDE_EMAIL_RECIPIENT']
                p[:email] = ENV['OVERRIDE_EMAIL_RECIPIENT']
              end
              p.merge :type => 'to'
            end,
            :headers => {
                         :"Reply-To" => email_info[:reply_to]
            }
          }
          m.messages.send message
        end
      end
    end
  end
end
