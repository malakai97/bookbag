require "bookbag/settings"

module BookBag
  # A wrapper for the dpn-info.txt file within the bag.  Once created, it does not change with
  # changes made to the underlying txt file; in that case, a new Bag should be created.
  class DPNInfoTxt
    # @overload initialize(opts)
    #   Build a DPNInfoText from scratch by supplying an options hash.
    #   @param [Hash] opts
    #   @option opts [String] :dpnObjectID
    #   @option opts [String] :localName
    #   @option opts [String] :ingestNodeName
    #   @option opts [String] :ingestNodeAddress
    #   @option opts [String] :ingestNodeContactName
    #   @option opts [String] :ingestNodeContactEmail
    #   @option opts [Fixnum] :version
    #   @option opts [String] :firstVersionObjectID
    #   @option opts [String] :bagTypeName
    #   @option opts [Array<String>] :interpretiveObjectIDs
    #   @option opts [Array<String>] :rightsObjectIDs
    def initialize(opts)
      @settings = DPN::Bagit::Settings.instance.config
      @dpnInfoKeysArrays = @settings[:bag][:dpn_info][:arrays]
      @dpnInfoKeysNonArrays = @settings[:bag][:dpn_info][:non_arrays]
      @dpnInfoErrors = []
      @dpnInfo = {}
      (@dpnInfoKeysNonArrays + @dpnInfoKeysArrays).each do |key|
        key = key.to_sym
        @dpnInfo[key] = opts[key]
      end
    end


    # Return a string that is the dpn-info.txt file.
    def to_s
      raise RuntimeError, "invalid dpn info txt!" unless valid?
      out = []
      @dpnInfoKeysNonArrays.each_key do |key|
        key = key.to_sym
        name = @settings[:bag][:dpn_info][key][:name]
        out << "#{name}: #{@dpnInfo[key]}"
      end
      @dpnInfoKeysArrays.each_key do |key|
        key = key.to_sym
        name = @settings[:bag][:dpn_info][key][:name]
        @dpnInfo[key].each do |value|
          out << "#{name}: #{value}"
        end
      end
      return out.join("\n")
    end


    # Check for validity
    # @return [Boolean]
    def valid?
      return @dpnInfoErrors.empty?
    end


    # Returns a list of any errors encountered on creation and validation.
    # @return [Array<String]
    def getErrors()
      return @dpnInfoErrors
    end


    # Get the value associated with the given field.
    # @param key [Symbol]
    def [](key)
      return @dpnInfo[key.to_sym]
    end

  end
end

