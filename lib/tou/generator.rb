module Tou
  # When included into an ActiveRecord, will generate a TOU and prefill it
  # into the "id" attribute if it is blank. Add this module to your records
  # to set their IDs using Tou.
  module Generator
    def self.included(into)
      into.before_validation :generate_and_write_touid!
      super
    end

    def generate_and_write_touid!
      write_attribute("id", Tou.uuid) if read_attribute("id").blank?
    end
  end
end
