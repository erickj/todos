module Todo
  module Mail
    class Persona

      attr_reader :email, :name

      def initialize(email, name='')
        @email = email
        @name = name || ''
      end

      def ==(other)
        return false unless other.is_a? Persona
        @email == other.email
      end
      alias :eql? :==

      def username
        @email.split('@', 2).first
      end
    end
  end
end
