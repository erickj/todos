module Ize
  def self.titleize(izeable)
    izeable.to_s.gsub('_', ' ').capitalize.gsub(/\s([a-z])/) { |m| ' %s'%[$1.upcase]}
  end
end
