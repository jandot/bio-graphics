require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/bio-graphics'

class TestPanel < Test::Unit::TestCase
  def test_draw_showcase
    my_panel = Bio::Graphics::Panel.new(500, :width => 1000)
    
    generic_track = my_panel.add_track('generic', false)
    line_track = my_panel.add_track('line', false, :line, [0,0,1])
    directed_track = my_panel.add_track('directed', false, :directed_generic, [0,1,0])
    triangle_track = my_panel.add_track('triangle', false, :triangle, [1,0,0])
    dot_track = my_panel.add_track('dot', false, :dot, [0,1,1])
    spliced_track = my_panel.add_track('spliced', false, :spliced, [1,0,0])
    directed_spliced_track = my_panel.add_track('directed_spliced', false, :directed_spliced, [1,0,1])
    
    generic_track.add_feature(Bio::Feature.new('clone', '250..375'), 'clone1', 'http://www.newsforge.com')
    generic_track.add_feature(Bio::Feature.new('clone', '54..124'), 'clone2', 'http://www.thearkdb.org')
    generic_track.add_feature(Bio::Feature.new('clone', '100..449'), 'clone3', 'http://www.google.com')
    
    line_track.add_feature(Bio::Feature.new('primer', 'complement(200..320)'), 'primer1')
    line_track.add_feature(Bio::Feature.new('primer', '355..480'), 'primer2', 'http://www.zdnet.co.uk')
    
    directed_track.add_feature(Bio::Feature.new('marker', '50..60'), 'marker1', 'http://www.google.com')
    directed_track.add_feature(Bio::Feature.new('marker','complement(80..120)'), 'marker2', 'http://www.sourceforge.net')
    
    triangle_track.add_feature(Bio::Feature.new('marker', '56'),'snp1')
    triangle_track.add_feature(Bio::Feature.new('marker', '103'), 'snp2','http://digg.com')
    
    dot_track.add_feature(Bio::Feature.new('marker', '56'), 'thing1')
    dot_track.add_feature(Bio::Feature.new('marker', '57'), 'thing3')
    dot_track.add_feature(Bio::Feature.new('marker', '114'), 'thing2','http://digg.com')

    spliced_track.add_feature(Bio::Feature.new('gene','join(34..52,109..183)'), 'gene1','http://news.bbc.co.uk')
    spliced_track.add_feature(Bio::Feature.new('gene','complement(join(170..231,264..299,350..360,409..445))'), 'gene2')
    spliced_track.add_feature(Bio::Feature.new('gene','join(134..152,209..283)'), 'gene3')
    
    directed_spliced_track.add_feature(Bio::Feature.new('gene','join(34..52,109..183)'), 'gene4', 'http://www.vrtnieuws.net')
    directed_spliced_track.add_feature(Bio::Feature.new('gene','complement(join(170..231,264..299,350..360,409..445))'), 'gene5', 'http://bioinformatics.roslin.ac.uk')
    directed_spliced_track.add_feature(Bio::Feature.new('gene','join(134..152,209..283)'), 'gene6')
    
    output_file = File.dirname(__FILE__) + '/output.png'
    my_panel.draw(output_file)
    system("display " + output_file + "& sleep 2 && kill $!")
    File.delete(output_file)
  end

  def test_arkdb_features
    my_panel = Bio::Graphics::Panel.new(4173015, :width => 600, :verticle => true)
    
    #Create and configure tracks
    scaffold_track = my_panel.add_track('scaffold', false)
    marker_track = my_panel.add_track('marker', true)
    clone_track = my_panel.add_track('clone', false)
    
    scaffold_track.colour = [1,0,0]
    marker_track.colour = [0,1,0]
    marker_track.glyph = :triangle
    clone_track.colour = [0,0,1]
    
    # Add data to tracks
    File.open(File.dirname(__FILE__) + '/data.txt').each do |line|
      line.chomp!
      accession, type, start, stop = line.split(/\t/)
      if type == 'scaffold'
        if start.nil?
          scaffold_track.add_feature(Bio::Feature.new('scaffold', '1..4173015'), accession)
        else
          scaffold_track.add_feature(Bio::Feature.new('scaffold', start + '..' + stop), accession, 'http://www.google.com')
        end
          
      elsif type == 'marker'
        marker_track.add_feature(Bio::Feature.new('marker', ((start.to_i + stop.to_i)/2).to_s), accession, 'http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=' + accession)
      elsif type == 'clone'
        clone_track.add_feature(Bio::Feature.new('clone', start + '..' + stop), accession)
      end
    end

    # And draw
    output_file = File.dirname(__FILE__) + '/output.png'
    my_panel.draw(output_file)

    system("display " + output_file + "& sleep 2 && kill $!")
    File.delete(output_file)    
  end

  def test_subfeatures
    my_panel = Bio::Graphics::Panel.new(500, :width => 600)
    
    track = my_panel.add_track('mrna')
    
    track.colour = [1,0,0]
    track.glyph = :spliced
    
    # Add data to tracks
    utr5 = Bio::Feature.new('utr', '100..150')
    cds = Bio::Feature.new('cds', 'join(150..225, 250..275, 310..330)')
    utr3 = Bio::Feature.new('utr', '330..375')

    transcript = Bio::Feature.new('transcript', 'join(100..225, 250..275, 310..375)', [], nil, [utr5, cds, utr3])
    
    transcript_graphic = track.add_feature(transcript, 'my_transcript')
    transcript_graphic.glyph = { 'utr' => :line, 'cds' => :spliced }
    
    # And draw
    output_file = File.dirname(__FILE__) + '/output.png'
    my_panel.draw(output_file)

    system("display " + output_file + "& sleep 2 && kill $!")
    File.delete(output_file)    
  end
  
  def test_feature_specific_colouring
    my_panel = Bio::Graphics::Panel.new(375, :width => 600)
    
    track = my_panel.add_track('mrna')
    
    track.colour = [1,0,0]
    track.glyph = :spliced
    
    # Add data to tracks
    track.add_feature(Bio::Feature.new('cds', 'join(100..200, 225..350)'), 'red_spliced')
    track.add_feature(Bio::Feature.new('cds', 'join(100..200, 225..350)'), 'green_spliced', nil, track.glyph, [0,1,0])
    track.add_feature(Bio::Feature.new('cds', 'join(100..200, 225..350)'), 'blue_generic', nil, :generic, [0,0,1])
    
    # And draw
    output_file = File.dirname(__FILE__) + '/output.png'
    my_panel.draw(output_file)

    system("display " + output_file + "& sleep 2 && kill $!")
    File.delete(output_file)    
  end  
end
