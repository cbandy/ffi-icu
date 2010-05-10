module ICU
  module CharDet

    def self.detect(string)
      detector = Detector.new
      res = detector.detect string
      detector.close

      res
    end

    class Detector
      Match = Struct.new(:name, :confidence, :language)

      def initialize
        @detector = Lib.check_error { |ptr| Lib.ucsdet_open(ptr) }
      end

      def input_filter_enabled?
        Lib.ucsdet_isInputFilterEnabled @detector
      end

      def input_filter_enabled=(bool)
        Lib.ucsdet_enableInputFilter(@detector, !!bool)
      end

      def declared_encoding=(str)
        Lib.check_error do |ptr|
          Lib.ucsdet_setDeclaredEncoding(@detector, str, str.bytesize, ptr)
        end
      end

      def close
        Lib.ucsdet_close @detector
      end

      def detect(str)
        set_text(str)

        match_ptr = Lib.check_error { |ptr| Lib.ucsdet_detect(@detector, ptr) }
        match_ptr_to_ruby(match_ptr) unless match_ptr.null?
      end

      def detect_all(str)
        set_text(str)

        matches_found_ptr = FFI::MemoryPointer.new :int
        array_ptr = Lib.check_error do |status|
          Lib.ucsdet_detectAll(@detector, matches_found_ptr, status)
        end

        length = matches_found_ptr.read_int
        array_ptr.read_array_of_pointer(length).map do |match|
          match_ptr_to_ruby(match)
        end
      end

      def detectable_charsets
        enum_ptr = Lib.check_error do |ptr|
          Lib.ucsdet_getAllDetectableCharsets(@detector, ptr)
        end

        result = Lib.enum_ptr_to_array(enum_ptr)
        Lib.uenum_close(enum_ptr)

        result
      end

      private

      def match_ptr_to_ruby(match_ptr)
        result = Match.new

        result.name       = Lib.check_error { |ptr| Lib.ucsdet_getName(match_ptr, ptr) }
        result.confidence = Lib.check_error { |ptr| Lib.ucsdet_getConfidence(match_ptr, ptr) }
        result.language   = Lib.check_error { |ptr| Lib.ucsdet_getLanguage(match_ptr, ptr) }

        result
      end

      def set_text(text)
        Lib.check_error do |status|
          Lib.ucsdet_setText(@detector, text, text.bytesize, status)
        end
      end

    end # Detector
  end # CharDet
end # ICU

