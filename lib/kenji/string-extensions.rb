# Kenji string extensions

module Kenji
  module StringExtensions

    refine String do

      def to_underscore!
        gsub!(/(.)([A-Z])/, '\1_\2').downcase!
      end

      def to_underscore
        clone.to_underscore!
      end

      def to_camelcase!
        replace(split('_').each(&:capitalize!).join(''))
      end

      def to_camelcase
        clone.to_camelcase!
      end
    end
  end
end
