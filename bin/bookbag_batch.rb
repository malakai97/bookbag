#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "bookbag"
require "thread"

common_output_dir = ARGV[1]
common_input_dir = ARGV[0]
raise ArgumentError unless common_input_dir
raise ArgumentError unless common_output_dir

large_rights = ["65c553c3-bbf1-4494-8f5e-1f134873e319"]
ia_rights = ["a10b5b3a-f216-4b90-9818-fc3eefd2a43b"]
interp = ["d0310294-f74c-4f22-9d32-bce452457e70"]
common_build_options = {
  type: :data,
  interpretive: interp
}
large_build_options = common_build_options.merge({rights: large_rights})
ia_build_options = common_build_options.merge({rights: ia_rights})

nodes = {
  texas: {},
  chron: {},
  aptrust: {}
}

nodes[:texas][:options] = {
  output_dir: File.join(common_output_dir, "texas"),
  ingest_node_name: "TDR",
  ingest_node_address: "Texas Digital Library\nPerry-Castaneda Library\n101 E. 21st Street\nAustin, TX 78705",
  ingest_node_contact_name: "Ryan Steans",
  ingest_node_contact_email: "rsteans@austin.utexas.edu",
}
nodes[:chron][:options] = {
  output_dir: File.join(common_output_dir, "chron"),
  ingest_node_name: "Chronopolis",
  ingest_node_address: "Institute for Advanced Computer Studies\nUniversity of Maryland\nCollege Park, MD 20740",
  ingest_node_contact_name: "Mike Ritter",
  ingest_node_contact_email: "shake@umiacs.umd.edu"
}
nodes[:aptrust][:options] = {
  output_dir: File.join(common_output_dir, "aptrust"),
  ingest_node_name: "Advanced Preservation Trust",
  ingest_node_address: "University of Virginia Library\nP.O. Box 400113\nCharlottesville, VA 22904-4113",
  ingest_node_contact_name: "Andrew Diamond",
  ingest_node_contact_email: "andrew.diamond@aptrust.org"
}

nodes.keys.each do |node|
  nodes[node][:input] = {}
  nodes[node][:output] = {}
  nodes[node][:input][:large] = File.readlines(File.join common_input_dir, node.to_s, "large.tsv")
  nodes[node][:input][:ia] = File.readlines(File.join common_input_dir, node.to_s, "open_ia_volumes.tsv")
  nodes[node][:output][:large] = File.join common_output_dir, node.to_s, "large"
  nodes[node][:output][:ia] = File.join common_output_dir, node.to_s, "ia"
end


q = Queue.new
nodes.keys.each do |node|
  node_builder = Bookbag::Builder.new(nodes[node][:options])
  nodes[node][:input][:large].each do |line|
    volume, location = line.split(" ")
    job_options = large_build_options.merge({name: volume, location: location})
    q.push [node_builder, job_options]
  end
  nodes[node][:input][:ia].each do |line|
    volume, location = line.split(" ")
    job_options = ia_build_options.merge({name: volume, location: location})
    q.push [node_builder, job_options]
  end
end

num_workers = 10
puts "Will begin bagging #{q.size} volumes"
puts "using #{num_workers} threads in 5 seconds..."
sleep 5

workers = (0..num_workers).map do
  Thread.new do
    begin
      while job = q.pop(true)
        job[0].public_send(:build, job[1])
      end
    rescue ThreadError
    end
  end
end; "ok"
workers.map(&:join); "ok"


