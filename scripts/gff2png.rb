#!/usr/bin/ruby
# == NAME
# gff2png.rb
#
# == USAGE
#  ./gff2png.rb [ -h | --help ]
#               -l | --length length_of_sequence
#               [ -i | --infile | < ] your_gff_file.txt
#               -o | --outfile your_output.png
#
# == DESCRIPTION
# This script parses a GFF file and creates a picture using Bio::Graphics. The
# flavour of GFF required is GFF3 (see http://www.sequenceontology.org/gff3.shtml).
#
# == OPTIONS
#  -h,--help::                 Show help
#  -l,--length=LENGTH::        Length of sequence. Required.
#  -i,--infile=INFILE::        Name of input file. STDIN if not defined.
#  -o,--outfile=OUTFILE::      Name of output file. Required.
#
# == FORMAT INPUT
# GFF3. See http://www.sequenceontology.org/gff3.shtml
# 
# == FORMAT OUTPUT
# A PNG picture.
#
# == AUTHOR
#  Dr Jan Aerts
#  jan.aerts@gmail.com

require '../lib/bio-graphics'
require 'rdoc/usage'
require 'optparse'
require 'ostruct'
require 'yaml'

### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.on("-h","--help",
        "Display the usage information") {RDoc::usage}
opts.on("-l","--length", "=LENGTH",
        "Length of the sequence") {|argument| options.seq_length = argument.to_i}
opts.on("-c","--config", "=CONFIG",
        "Name of config file") {|argument| options.config_file = argument}
opts.on("-i","--infile", "=INFILE",
        "Input file name") {|argument| options.infile = argument}
opts.on("-o","--outfile", "=OUTFILE",
        "Output file name") {|argument| options.outfile = argument}
opts.parse! rescue RDoc::usage('usage')

if options.seq_length.nil? or options.outfile.nil?
  RDoc::usage('usage')
end

if options.infile
  input_stream = File.open(options.infile)
else
  input_stream = $stdin
end

output_stream = File.new(options.outfile,'w')

### Actually do some stuff
tracks = Hash.new
my_panel = Bio::Graphics::Panel.new(0..options.seq_length)
input_stream.each_line do |line|
  next if line =~ /^#/
  line.chomp!
  seqid, source, feature_type, start, stop, score, strand, phase, attributes_string = line.split(/\t/)
  
  attributes_hash = Hash.new
  attributes_string.gsub!(/ +; +/,';')
  attributes = attributes_string.split(/;/)
  attributes.each do |a|
    key, value = a.split(/=/)
    attributes_hash[key] = value
  end
  
  if ! tracks.has_key?(feature_type)
    tracks[feature_type] = my_panel.add_track(feature_type)
  end
  
  location = start + '..' + stop
  if strand == '-'
    location = 'complement(' + location + ')'
  end
  tracks[feature_type].add_feature(Bio::Feature.new(feature_type, location), :label => attributes_hash['Name'])
end

if options.config_file
  YAML::load_documents(File.open(options.config_file)) do |p|
    tracks[p['track']].glyph = p['glyph'] unless p['glyph'].nil?
    tracks[p['track']].colour = p['colour'] unless p['colour'].nil?
  end
end

my_panel.draw(options.outfile)

### Wrap everything up
output_stream.close
input_stream.close
