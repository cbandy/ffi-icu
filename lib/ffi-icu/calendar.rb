module ICU
  class Calendar
    class << self
      def available_locales
        (0...Lib.ucal_countAvailable).map do |idx|
          Lib.ucal_getAvailable idx
        end
      end
    end
  end
end
