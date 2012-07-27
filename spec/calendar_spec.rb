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
  end
end
