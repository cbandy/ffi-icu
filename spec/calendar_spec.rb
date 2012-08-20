# encoding: UTF-8

require 'spec_helper'

module ICU
  describe Calendar do
    describe 'available locales' do
      subject { Calendar.available_locales }

      it { should be_an Array }
      it { should_not be_empty }
      its(:first) { should be_a String }
    end

    describe 'timezones' do
      subject { Calendar.timezones }

      it { should be_an Array }
      it { should_not be_empty }
      its(:first) { should be_a String }

      describe 'canonical timezone identifier' do
        it 'returns a canonical system identifier' do
          Calendar.canonical_timezone_identifier('GMT').should == 'Etc/GMT'
        end

        it 'returns a normalized custom identifier' do
          if Gem::Version.new('4.2') <= Gem::Version.new(Lib.version)
            Calendar.canonical_timezone_identifier('GMT-6').should == 'GMT-06:00'
            Calendar.canonical_timezone_identifier('GMT+1:15').should == 'GMT+01:15'
          else
            Calendar.canonical_timezone_identifier('GMT-6').should == 'GMT-0600'
            Calendar.canonical_timezone_identifier('GMT+1:15').should == 'GMT+0115'
          end
        end
      end

      describe 'country timezones' do
        it 'returns a list of timezones associated with a country' do
          Calendar.country_timezones('DE').should == ['Europe/Berlin']
          Calendar.country_timezones('US').should include 'America/Chicago'
          Calendar.country_timezones('CN').should_not include 'UTC'
        end

        it 'returns a list of timezones associated with no countries' do
          Calendar.country_timezones(nil).should include 'UTC'
        end
      end

      describe 'daylight savings' do
        it 'returns the milliseconds added during daylight savings time' do
          Calendar.dst_savings('America/Chicago').should == 3_600_000
          Calendar.dst_savings('GMT').should == 0
        end
      end

      describe 'timezone data version' do
        subject { Calendar.timezone_data_version }

        it { should be_a String }
      end

      describe 'default timezone' do
        subject { Calendar.default_timezone }

        let(:timezone) do
          timezones = Calendar.timezones
          timezones.delete(Calendar.default_timezone)
          timezones.respond_to?(:sample) ? timezones.sample : timezones.choice
        end

        it { should be_a String }

        it 'can be assigned' do
          (Calendar.default_timezone = timezone).should == timezone
          Calendar.default_timezone.should == timezone
        end
      end

      if Gem::Version.new('4.8') <= Gem::Version.new(Lib.version)
        describe 'timezone identifiers' do
          it 'returns timezones of a particular type' do
            Calendar.timezone_identifiers(:any).should include 'UTC'
            Calendar.timezone_identifiers(:canonical).should include 'Factory'
            Calendar.timezone_identifiers(:canonical_location).should include 'America/Chicago'
          end

          it 'filters timezones by country' do
            Calendar.timezone_identifiers(:any, 'US').should_not include 'UTC'
            Calendar.timezone_identifiers(:canonical, 'DE').should == ['Europe/Berlin']
          end

          it 'filters timezones by offset in milliseconds' do
            Calendar.timezone_identifiers(:any, nil, -10_800_000).should include 'BET'
            Calendar.timezone_identifiers(:canonical, nil, 3_600_000).should include 'Europe/Berlin'
          end
        end
      end
    end
  end
end
