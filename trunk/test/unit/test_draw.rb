require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/bio-graphics'

class TestPanel < Test::Unit::TestCase
  def test_draw_showcase
    my_panel = Bio::Graphics::Panel.new(500, 1000, false)
    
    generic_track = my_panel.add_track('generic', false)
    line_track = my_panel.add_track('line', false, [0,0,1], :line)
    directed_track = my_panel.add_track('directed', false, [0,1,0], :directed_generic)
    triangle_track = my_panel.add_track('triangle', false, [1,0,0], :triangle)
    spliced_track = my_panel.add_track('spliced', false, [1,0,0], :spliced)
    directed_spliced_track = my_panel.add_track('directed_spliced', false, [1,0,1], :directed_spliced)
    
    generic_track.add_feature('clone1','250..375', 'http://www.newsforge.com')
    generic_track.add_feature('clone2','54..124', 'http://www.thearkdb.org')
    generic_track.add_feature('clone3','100..449', 'http://www.google.com')
    
    line_track.add_feature('primer1','complement(200..320)')
    line_track.add_feature('primer2','355..480', 'http://www.zdnet.co.uk')
    
    directed_track.add_feature('marker1','50..60', 'http://www.google.com')
    directed_track.add_feature('marker2','complement(80..120)', 'http://www.sourceforge.net')
    
    triangle_track.add_feature('snp1','56')
    triangle_track.add_feature('snp2','103','http://digg.com')
    
    spliced_track.add_feature('gene1','join(34..52,109..183)','http://news.bbc.co.uk')
    spliced_track.add_feature('gene2','complement(join(170..231,264..299,350..360,409..445))')
    spliced_track.add_feature('gene3','join(134..152,209..283)')
    
    directed_spliced_track.add_feature('gene4','join(34..52,109..183)', 'http://www.vrtnieuws.net')
    directed_spliced_track.add_feature('gene5','complement(join(170..231,264..299,350..360,409..445))', 'http://bioinformatics.roslin.ac.uk')
    directed_spliced_track.add_feature('gene6','join(134..152,209..283)')
    
    output_file = File.dirname(__FILE__) + '/output.png'
    my_panel.draw(output_file)
    system("display " + output_file + "& sleep 2 && kill $!")
    File.delete(output_file)
  end

  def test_arkdb_features
    my_panel = Bio::Graphics::Panel.new(4173015, 800, false, 1, 4173015)
    
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
    output_file = File.dirname(__FILE__) + '/output.png'
    my_panel.draw(output_file)
    system("display " + output_file + "& sleep 2 && kill $!")
    File.delete(output_file)
  end

end

