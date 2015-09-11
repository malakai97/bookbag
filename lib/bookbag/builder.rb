require "bagit"
require "bookbag/settings"
require "bookbag/dpn_info_txt"

module Bookbag
  class Builder


    # Create a new builder instance.
    # @param [String] output_directory The directory under which
    #   the created bags will be stored.
    def initialize(options)
      raise ArgumentError, "output_dir required" unless options[:output_dir]
      @output_directory = File.expand_path(options[:output_dir])
      address = [
        "University of Michigan Library",
        "818 Hatcher Graduate Library South",
        "913 S. University Avenue",
        "Ann Arbor, MI 48109-1190"
      ].join("\n")
      @bag_info = {
        'Source-Organization' => "HathiTrust Digital Library",
        'Organization-Address' => address,
        'Contact-Name' => "Bryan Hockey",
        'Contact-Phone' => "(734)763-8948",
        'Contact-Email' => "bhock@umich.edu",
        'Bag-Group-Identifier' => "",
        'Bag-Count' => ""
      }
      @ingest_node_name = options[:ingest_node_name] || Bookbag::Settings[:bag][:dpn_info][:ingestNodeName][:default]
      @ingest_node_address = options[:ingest_node_address] || Bookbag::Settings[:bag][:dpn_info][:ingestNodeAddress][:default]
      @ingest_node_contact_name = options[:ingest_node_contact_name] || Bookbag::Settings[:bag][:dpn_info][:ingestNodeContactName][:default]
      @ingest_node_contact_email = options[:ingest_node_contact_email] || Bookbag::Settings[:bag][:dpn_info][:ingestNodeContactEmail][:default]
    end


    # Create a bag from scratch yo'
    # @param [Hash] opts
    # @option opts [String] :name  <ht_namespace>.<ht_id>, or any name you wish.
    #   This will be put into the local_id field.
    # @option opts [Symbol] :type One of :data, :rights, or :interpretive
    # @option opts [String] :location The location of the HT volume.  Generally,
    #   the directory that contains the zip.
    # @option opts [Array<String>] :rights Array of uuids of the rights bags for
    #  this bag.
    # @option opts [Array<String>] :interpretive Array of uuids of the interpretive
    #   bags for this bag.
    def build(opts)
      uuid = SecureRandom.uuid

      bag = BagIt::Bag.new File.join(@output_directory, uuid)
      path = File.join File.expand_path(opts[:location]), "**", "*"
      Dir.glob(path).each do |filepath|
        bag.add_file(File.basename(filepath), filepath)
      end

      dpn_info_opts = {
        dpnObjectID: uuid,
        localName: "#{opts[:name]}",
        ingestNodeName: @ingest_node_name,
        ingestNodeAddress: @ingest_node_address,
        ingestNodeContactName: @ingest_node_contact_name,
        ingestNodeContactEmail: @ingest_node_contact_email,
        version: 1,
        firstVersionObjectID: uuid,
        bagTypeName: opts[:type].to_s.downcase,
        interpretiveObjectIDs: opts[:interpretive],
        rightsObjectIDs: opts[:rights]
      }

      dpn_info_txt = Bookbag::DPNInfoTxt.new(dpn_info_opts)

      bag.add_tag_file(File.join(Bookbag::Settings[:bag][:dpn_dir], Bookbag::Settings[:bag][:dpn_info][:name])) do |io|
        io.puts dpn_info_txt.to_s
      end

      bag.write_bag_info(@bag_info)

      bag.manifest!
    end

  end
end