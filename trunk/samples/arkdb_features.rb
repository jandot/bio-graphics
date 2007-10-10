require File.dirname(__FILE__) + '/../lib/bio-graphics'

#Initialize graphic for a nucleotide sequence of 4173015 bp, zooming in on the
#region 11111..3333333
my_panel = Bio::Graphics::Panel.new(4173015, 800, false, 11111, 3333333)
#my_panel = Bio::Graphics::Panel.new(4173015, 800, false, 1, 4173015)

#Create and configure tracks
scaffold_track = my_panel.add_track('scaffold')
marker_track = my_panel.add_track('marker')
clone_track = my_panel.add_track('clone')

scaffold_track.colour = [1,0,0]
marker_track.colour = [0,1,0]
marker_track.glyph = 'triangle'
clone_track.colour = [0,0,1]

# Add data to tracks
File.open('data.txt').each do |line|
  line.chomp!
  accession, type, start, stop = line.split(/\t/)
  if type == 'scaffold'
    if start.nil?
      scaffold_track.add_feature(accession)
    else
      scaffold_track.add_feature(accession, start + '..' + stop)
    end
    
  elsif type == 'marker'
    marker_track.add_feature(accession, ((start.to_i + stop.to_i)/2).to_s, 'http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=' + accession)
  elsif type == 'clone'
    clone_track.add_feature(accession, start + '..' + stop)
  end
end

# And draw
my_panel.draw('my_panel.png')
