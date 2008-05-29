require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/bio-graphics'

class TestImageMap < Test::Unit::TestCase
  def setup
    @generated_files = Array.new
    
    @horizontal_imagemap = <<END_OF_STRING
<html>
<body>
<map name="image_map" border="1">
<area shape="rect" coords="209.075452640357 82 252.5194373852 92" href="http://www.google.com"/>
<area shape="rect" coords="253.957390519804 82 451.51613401821 92" href="http://www.google.com"/>
<area shape="rect" coords="132.966578121574 137 142.966578121574 147" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00049788"/>
<area shape="rect" coords="135.392018720278 167 145.392018720278 177" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00033347"/>
<area shape="rect" coords="181.068633829497 197 191.068633829497 207" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00049753"/>
<area shape="rect" coords="205.969047559139 227 215.969047559139 237" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00049743"/>
<area shape="rect" coords="217.47799253058 257 227.47799253058 267" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00050962"/>
<area shape="rect" coords="430.77140269086 137 440.77140269086 147" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00049746"/>
</map>
<img border='1' src='./test_horizontal_imagemap.png' usemap='#image_map' />
</body>
</html>
END_OF_STRING
    
    @vertical_imagemap = <<END_OF_STRING
<html>
<body>
<map name="image_map" border="1">
<area shape="rect" coords="82 347.4805626148 92 390.924547359643" href="http://www.google.com"/>
<area shape="rect" coords="82 148.48386598179 92 346.042609480196" href="http://www.google.com"/>
<area shape="rect" coords="137 457.033421878426 147 467.033421878426" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00049788"/>
<area shape="rect" coords="167 454.607981279722 177 464.607981279722" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00033347"/>
<area shape="rect" coords="197 408.931366170503 207 418.931366170503" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00049753"/>
<area shape="rect" coords="227 384.030952440861 237 394.030952440861" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00049743"/>
<area shape="rect" coords="257 372.52200746942 267 382.52200746942" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00050962"/>
<area shape="rect" coords="137 159.22859730914 147 169.22859730914" href="http://www.thearkdb.org/arkdb/do/getMarkerDetail?accession=ARKMKR00049746"/>
</map>
<img border='1' src='./test_vertical_imagemap.png' usemap='#image_map' />
</body>
</html>
END_OF_STRING
  end
  
  def test_horizontal_imagemap
    my_panel = Bio::Graphics::Panel.new(4173015, :width => 600, :clickable => true)
    
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
    html_file = output_file.sub(/\.png$/, '.html')
    @generated_files.push(output_file)
    @generated_files.push(html_file)

    my_panel.draw(output_file)
    
    assert_equal(@horizontal_imagemap, File.read(html_file))
  end

  def test_vertical_imagemap
    my_panel = Bio::Graphics::Panel.new(4173015, :width => 600, :clickable => true, :vertical => true)
    
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
    html_file = output_file.sub(/\.png$/, '.html')
    @generated_files.push(output_file)
    @generated_files.push(html_file)

    my_panel.draw(output_file)
    
    assert_equal(@vertical_imagemap, File.read(html_file))
  end
  
  def teardown
    @generated_files.each do |p|
      File.delete(p)
    end
  end
end