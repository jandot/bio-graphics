require File.dirname(__FILE__) + '/../lib/bio-graphics'

#Initialize graphic for a nucleotide sequence of 4173015 bp, zooming in on the
#region 11111..3333333
my_panel = Bio::Graphics::Panel.new(11111..3333333, :width => 600, :clickable => true)

#Create and configure tracks
scaffold_track = my_panel.add_track('scaffold', :label => false)
marker_track = my_panel.add_track('marker',
                                  :colour => lambda do |feature|
                                    if feature.label =~ /3$/
                                      [1,0,0]
                                    else
                                      [0,1,1]
                                    end
                                  end
                                  )
clone_track = my_panel.add_track('clone', :label => false,
                                    :colour => lambda do |feature|
                                      return [rand,rand,0]
                                    end
)

#scaffold_track.colour = [1,0,0]
#marker_track.colour = [0,1,0]
marker_track.glyph = :triangle
#clone_track.colour = [0,0,1]

# Add data to tracks
File.open('data.txt').each do |line|
  line.chomp!
  accession, type, start, stop = line.split(/\t/)
  if type == 'scaffold'
    if start.nil?
      scaffold_track.add_feature(Bio::Feature.new('scaffold', '1..4173015'), :label => accession)
    else
      scaffold_track.add_feature(Bio::Feature.new('scaffold', start + '..' + stop), :label => accession, :link => 'http://www.google.com/search?q=' + accession)
    end
    
  elsif type == 'marker'
    marker_track.add_feature(Bio::Feature.new('marker', ((start.to_i + stop.to_i)/2).to_s), :label => accession, :link => 'http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=' + accession)
  elsif type == 'clone'
    clone_track.add_feature(Bio::Feature.new('clone', start + '..' + stop), :label => accession)
  end
end

# And draw
my_panel.draw('my_panel.png')
