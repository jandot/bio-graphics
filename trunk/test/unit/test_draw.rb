require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/bio-graphics'

class TestPanel < Test::Unit::TestCase
  def setup
    @generated_pictures = Array.new
  end
  
  def test_draw_showcase
    my_panel = Bio::Graphics::Panel.new(500, :width => 1000)
    
    generic_track = my_panel.add_track('generic', :label => false)
    line_track = my_panel.add_track('line', :label => false, :glyph => :line, :colour => [0,0,1])
    line_with_handles_track = my_panel.add_track('line with handles', :label => false, :glyph => :line_with_handles, :colour => [0,0,1])
    directed_track = my_panel.add_track('directed', :label => false, :glyph => :directed_generic, :colour => [0,1,0])
    triangle_track = my_panel.add_track('triangle', :label => false, :glyph => :triangle, :colour => [1,0,0])
    dot_track = my_panel.add_track('dot', :label => false, :glyph => :dot, :colour => [0,1,1])
    spliced_track = my_panel.add_track('spliced', :label => false, :glyph => :spliced, :colour => [1,0,0])
    directed_spliced_track = my_panel.add_track('directed_spliced', :label => false, :glyph => :directed_spliced, :colour => [1,0,1])
    
    generic_track.add_feature(Bio::Feature.new('clone', '250..375'), :label => 'clone1', :link => 'http://www.newsforge.com')
    generic_track.add_feature(Bio::Feature.new('clone', '54..124'), :label => 'clone2', :link => 'http://www.thearkdb.org')
    generic_track.add_feature(Bio::Feature.new('clone', '100..449'), :label => 'clone3', :link => 'http://www.google.com')
    
    line_track.add_feature(Bio::Feature.new('primer', 'complement(200..320)'), :label => 'primer1')
    line_track.add_feature(Bio::Feature.new('primer', '355..480'), :label => 'primer2', :link => 'http://www.zdnet.co.uk')

    line_with_handles_track.add_feature(Bio::Feature.new('primer', 'complement(200..320)'), :label => 'primer1')
    line_with_handles_track.add_feature(Bio::Feature.new('primer', '355..480'), :label => 'primer2', :link => 'http://www.zdnet.co.uk')
    
    directed_track.add_feature(Bio::Feature.new('marker', '50..60'), :label => 'marker1', :link => 'http://www.google.com')
    directed_track.add_feature(Bio::Feature.new('marker','complement(80..120)'), :label => 'marker2', :link => 'http://www.sourceforge.net')
    
    triangle_track.add_feature(Bio::Feature.new('marker', '56'), :label => 'snp1')
    triangle_track.add_feature(Bio::Feature.new('marker', '103'), :label => 'snp2', :link => 'http://digg.com')
    
    dot_track.add_feature(Bio::Feature.new('marker', '56'), :label => 'thing1')
    dot_track.add_feature(Bio::Feature.new('marker', '57'), :label => 'thing3')
    dot_track.add_feature(Bio::Feature.new('marker', '114'), :label => 'thing2', :link => 'http://digg.com')

    spliced_track.add_feature(Bio::Feature.new('gene','join(34..52,109..183)'), :label => 'gene1', :link => 'http://news.bbc.co.uk')
    spliced_track.add_feature(Bio::Feature.new('gene','complement(join(170..231,264..299,350..360,409..445))'), :label => 'gene2')
    spliced_track.add_feature(Bio::Feature.new('gene','join(134..152,209..283)'), :label => 'gene3')
    
    directed_spliced_track.add_feature(Bio::Feature.new('gene','join(34..52,109..183)'), :label => 'gene4', :link => 'http://www.vrtnieuws.net')
    directed_spliced_track.add_feature(Bio::Feature.new('gene','complement(join(170..231,264..299,350..360,409..445))'), :label => 'gene5', :link => 'http://bioinformatics.roslin.ac.uk')
    directed_spliced_track.add_feature(Bio::Feature.new('gene','join(134..152,209..283)'), :label => 'gene6')
    
    output_file = File.dirname(__FILE__) + '/' + @method_name + '.png'
    @generated_pictures.push(output_file)
    
    my_panel.draw(output_file)
    system("display " + output_file + "& sleep 2 && kill $!")
  end

  def test_outside_border
    my_panel = Bio::Graphics::Panel.new(500, :width => 1000, :display_range => 100..400)
    
    spliced_track = my_panel.add_track('spliced', :label => false, :glyph => :spliced, :colour => [1,0,0])
    directed_spliced_track = my_panel.add_track('directed_spliced', :label => false, :glyph => :directed_spliced, :colour => [1,0,1])

    spliced_track.add_feature(Bio::Feature.new('gene','join(34..52,109..183)'), :label => 'gene1',:link => 'http://news.bbc.co.uk')
    spliced_track.add_feature(Bio::Feature.new('gene','complement(join(170..231,264..299,350..360,409..445))'), :label => 'gene2')
    spliced_track.add_feature(Bio::Feature.new('gene','join(134..152,209..283)'), :label => 'gene3')
    
    directed_spliced_track.add_feature(Bio::Feature.new('gene','join(34..52,109..183)'), :label => 'gene4', :link => 'http://www.vrtnieuws.net')
    directed_spliced_track.add_feature(Bio::Feature.new('gene','complement(join(170..231,264..299,350..360,409..445))'), :label => 'gene5', :link => 'http://bioinformatics.roslin.ac.uk')
    directed_spliced_track.add_feature(Bio::Feature.new('gene','join(134..152,209..283)'), :label => 'gene6')
    
    output_file = File.dirname(__FILE__) + '/' + @method_name + '.png'
    @generated_pictures.push(output_file)
    
    my_panel.draw(output_file)
    system("display " + output_file + "& sleep 2 && kill $!")
  end
  
  def test_arkdb_features
    my_panel = Bio::Graphics::Panel.new(4173015, :width => 600, :vertical => true)
    
    #Create and configure tracks
    scaffold_track = my_panel.add_track('scaffold', :label => false)
    marker_track = my_panel.add_track('marker', :label => true)
    clone_track = my_panel.add_track('clone', :label => false)
    
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
          scaffold_track.add_feature(Bio::Feature.new('scaffold', '1..4173015'), :label => accession)
        else
          scaffold_track.add_feature(Bio::Feature.new('scaffold', start + '..' + stop), :label => accession, :link => 'http://www.google.com')
        end
          
      elsif type == 'marker'
        marker_track.add_feature(Bio::Feature.new('marker', ((start.to_i + stop.to_i)/2).to_s), :label => accession, :link => 'http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=' + accession)
      elsif type == 'clone'
        clone_track.add_feature(Bio::Feature.new('clone', start + '..' + stop), :label => accession)
      end
    end

    # And draw
    output_file = File.dirname(__FILE__) + '/' + @method_name + '.png'
    @generated_pictures.push(output_file)

    my_panel.draw(output_file)

    system("display " + output_file + "& sleep 2 && kill $!")
  end

  def test_subregion
    my_panel = Bio::Graphics::Panel.new(4173015, :display_range => 2500000..3500000, :width => 600)
    
    #Create and configure tracks
    scaffold_track = my_panel.add_track('scaffold', :label => false)
    marker_track = my_panel.add_track('marker', :label => true)
    clone_track = my_panel.add_track('clone', :label => false)
    
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
          scaffold_track.add_feature(Bio::Feature.new('scaffold', '1..4173015'), :label => accession)
        else
          scaffold_track.add_feature(Bio::Feature.new('scaffold', start + '..' + stop), :label => accession, :link => 'http://www.google.com')
        end
          
      elsif type == 'marker'
        marker_track.add_feature(Bio::Feature.new('marker', ((start.to_i + stop.to_i)/2).to_s), :label => accession, :link => 'http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=' + accession)
      elsif type == 'clone'
        clone_track.add_feature(Bio::Feature.new('clone', start + '..' + stop), :label => accession)
      end
    end

    # And draw
    output_file = File.dirname(__FILE__) + '/' + @method_name + '.png'
    @generated_pictures.push(output_file)

    my_panel.draw(output_file)

    system("display " + output_file + "& sleep 2 && kill $!")
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
    
    transcript_graphic = track.add_feature(transcript, :label => 'my_transcript')
    transcript_graphic.glyph = { 'utr' => :line, 'cds' => :spliced }
    
    # And draw
    output_file = File.dirname(__FILE__) + '/' + @method_name + '.png'
    @generated_pictures.push(output_file)

    my_panel.draw(output_file)

    system("display " + output_file + "& sleep 2 && kill $!")
  end
  
  def test_feature_specific_colouring
    my_panel = Bio::Graphics::Panel.new(375, :display_range => 100..370, :width => 600)
    
    track = my_panel.add_track('mrna')
    
    track.colour = [1,0,0]
    track.glyph = :spliced
    
    # Add data to tracks
    track.add_feature(Bio::Feature.new('cds', 'join(100..200, 225..350)'), :label => 'red_spliced')
    track.add_feature(Bio::Feature.new('cds', 'join(100..200, 225..350)'), :label => 'green_spliced', :colour => [0,1,0])
    track.add_feature(Bio::Feature.new('cds', 'join(100..200, 225..350)'), :label => 'blue_generic', :colour => [0,0,1])
    
    # And draw
    output_file = File.dirname(__FILE__) + '/' + @method_name + '.png'
    @generated_pictures.push(output_file)

    my_panel.draw(output_file)

    system("display " + output_file + "& sleep 2 && kill $!")
  end
  
  def teardown
    @generated_pictures.each do |p|
      File.delete(p)
    end
  end
end
