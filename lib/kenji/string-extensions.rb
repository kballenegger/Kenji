# Kenji string extensions

module Kenji
  module StringExtensions
    refine String do
      def to_underscore!
        self.gsub!(/(.)([A-Z])/,'\1_\2').downcase!
      end
      def to_underscore
        self.clone.to_underscore!
      end
      def to_camelcase!
        self.replace self.split('_').each{ |s| s.capitalize! }.join('')
      end
      def to_camelcase
        self.clone.to_camelcase!
      end
    end
  end
end
