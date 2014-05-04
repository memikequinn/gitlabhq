module Vapors
  class BaseVaporService
    class VaporCountError < StandardError;
    end
    attr_accessor :vapor

    def initialize(vapor)
      enough_vapors!
      @vapor = vapor
    end

    def enough_vapors!
      if Vapor.count < 2
        Rails.logger.warn 'Tried to move projects off but nowhere to go... only one vapor configured'
        raise VaporCountError.new "Not enough vapors to do anything, create more"
      end
    end

  end
end