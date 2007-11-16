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
#  Bioinformatics Group
#  Roslin Institute

require '../lib/bio-graphics'
require 'rdoc/usage'
require 'optparse'
require 'ostruct'

### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.on("-h","--help",
        "Display the usage information") {RDoc::usage}
opts.on("-l","--length", "=LENGTH",
        "Length of the sequence") {|argument| options.seq_length = argument.to_i}
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
features = Array.new
my_panel = Bio::Graphics::Panel.new(options.seq_length)
input_stream.each_line do |line|
  next if line =~ /^#/
  line.chomp!
  seqid, source, type, start, stop, score, strand, phase, attributes_string = line.split(/\t/)
  
  attributes_hash = Hash.new
  attributes_string.gsub!(/ +; +/,';')
  attributes = attributes_string.split(/;/)
  attributes.each do |a|
    key, value = a.split(/=/)
    attributes_hash[key] = value
  end

  features.push([Bio::Feature.new(type, start + '..' + stop), attributes_hash['Name']])
end

my_track = my_panel.add_track('data')
my_track.glyph = :generic

features.each do |f|
  my_track.add_feature(f[0], f[1])
end
my_panel.draw(options.outfile)

### Wrap everything up
output_stream.close
input_stream.close
