module ICU
  class Calendar
    class << self
      def available_locales
        (0...Lib.ucal_countAvailable).map do |idx|
          Lib.ucal_getAvailable idx
        end
      end

      def canonical_timezone_identifier(timezone)
        is_system_id = FFI::MemoryPointer.new(:int8_t)
        timezone = UCharPointer.from_string(timezone + "\0")

        Lib::Util.read_uchar_buffer(256) do |result, error|
          Lib.ucal_getCanonicalTimeZoneID(
            timezone, -1,
            result, result.size / UCharPointer::TYPE_SIZE,
            is_system_id,
            error
          )
        end
      end

      def country_timezones(country)
        enum_ptr = Lib.check_error do |error|
          Lib.ucal_openCountryTimeZones(country, error)
        end

        begin
          Lib.enum_ptr_to_array(enum_ptr)
        ensure
          Lib.uenum_close(enum_ptr)
        end
      end

      def default_timezone
        Lib::Util.read_uchar_buffer(256) do |result, error|
          Lib.ucal_getDefaultTimeZone(result, result.size, error)
        end
      end

      def default_timezone=(zone)
        Lib.check_error do |error|
          Lib.ucal_setDefaultTimeZone(UCharPointer.from_string(zone + "\0"), error)
        end
      end

      def dst_savings(zone)
        Lib.check_error do |error|
          Lib.ucal_getDSTSavings(UCharPointer.from_string(zone + "\0"), error)
        end
      end

      def timezone_data_version
        Lib.check_error { |error| Lib.ucal_getTZDataVersion(error) }
      end

      def timezone_identifiers(type, region = nil, offset = nil)
        offset = FFI::MemoryPointer.new(:int32_t).write_int32(offset) unless offset.nil?

        enum_ptr = Lib.check_error do |error|
          Lib.ucal_openTimeZoneIDEnumeration(type, region, offset, error)
        end

        begin
          Lib.enum_ptr_to_array(enum_ptr)
        ensure
          Lib.uenum_close(enum_ptr)
        end
      end

      def timezones
        enum_ptr = Lib.check_error { |error| Lib.ucal_openTimeZones(error) }

        begin
          Lib.enum_ptr_to_array(enum_ptr)
        ensure
          Lib.uenum_close(enum_ptr)
        end
      end
    end
  end
end
