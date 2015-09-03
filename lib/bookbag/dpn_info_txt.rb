require "bookbag/settings"

module Bookbag
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
      @array_keys = Bookbag::Settings[:bag][:dpn_info][:arrays]
      @non_array_keys = Bookbag::Settings[:bag][:dpn_info][:non_arrays]
      @errors = []
      @info = {}
      (@non_array_keys + @array_keys).each do |key|
        key = key.to_sym
        @info[key] = opts[key]
      end
    end


    # Return a string that is the dpn-info.txt file.
    def to_s
      raise RuntimeError, "invalid dpn info txt!" unless valid?
      out = []
      @non_array_keys.each do |key|
        key = key.to_sym
        name = Bookbag::Settings[:bag][:dpn_info][key][:name]
        out << "#{name}: #{@info[key]}"
      end
      @array_keys.each do |key|
        key = key.to_sym
        name = Bookbag::Settings[:bag][:dpn_info][key][:name]
        @info[key].each do |value|
          out << "#{name}: #{value}"
        end
      end
      return out.join("\n")
    end


    # Check for validity
    # @return [Boolean]
    def valid?
      return errors.empty?
    end


    # Returns a list of any errors encountered on creation and validation.
    # @return [Array<String]
    def errors
      return @errors
    end


    # Get the value associated with the given field.
    # @param key [Symbol]
    def [](key)
      return @info[key.to_sym]
    end

  end
end

