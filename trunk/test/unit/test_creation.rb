require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/bio-graphics'

class TestPanel < Test::Unit::TestCase
  def test_panel_creation
    panel = Bio::Graphics::Panel.new(1000, :width => 500, :clickable => false,
                                     :display_range => 0..1000)
    assert_equal(1000, panel.length)
    assert_equal(500, panel.width)
    assert_equal(false, panel.clickable)
    assert_equal(0, panel.display_start)
    assert_equal(1000, panel.display_stop)
    assert_equal(1000/500, panel.rescale_factor)
    assert_equal(0, panel.tracks.length)
  end
  
  def test_panel_creation_out_of_boundaries
    panel = Bio::Graphics::Panel.new(1000, :width => 500, :clickable => false,
                                     :display_range => -7..5000)
    assert_same(0, panel.display_start)
    assert_same(1000, panel.display_stop)
  end
  
end

class TestTrack < Test::Unit::TestCase
  def setup
    @panel = Bio::Graphics::Panel.new(1000, :width => 500, :clickable => false,
                                      :display_range => 0..1000)
  end

  def test_track_creation
    track = @panel.add_track('test_track', :label => false, :glyph => :generic, :colour => [1,0,0])
    assert_equal('test_track', track.name)
    assert_equal([1,0,0], track.colour)
    assert_equal(:generic, track.glyph)
    assert_equal(1, @panel.tracks.length)
    assert_equal(0, track.features.length)
  end
end

class TestRuler < Test::Unit::TestCase
  def test_scaling_factor
    panel = Bio::Graphics::Panel.new(1000, :width => 600, :display_range => 0..1000)
    ruler = Bio::Graphics::Ruler.new(panel)
    assert_equal(1,ruler.scaling_factor(5,1000/600))
    assert_equal(2,ruler.scaling_factor(5,1000/500))
    assert_equal(1,ruler.scaling_factor(5,500/500))
  end

  def test_drawing
    panel = Bio::Graphics::Panel.new(375, :display_range => 100..370, :width => 600)
    ruler = Bio::Graphics::Ruler.new(panel)

    assert_equal(270.0/600.0,panel.rescale_factor)
    assert_equal(1,ruler.scaling_factor)
    assert_equal(5,ruler.minor_tick_distance)
    assert_equal(50,ruler.major_tick_distance)
    assert_equal(100,ruler.first_tick_position)
    
    i = 0
    ruler.first_tick_position.step(panel.display_stop, ruler.minor_tick_distance) do |tick|
      assert(i*ruler.min_pixels_per_tick,(tick - panel.display_start) / panel.rescale_factor)
      i += 1
    end    
  end
end

class TestFeature < Test::Unit::TestCase
  def setup
    @panel = Bio::Graphics::Panel.new(1000, :width => 500)
    @track = @panel.add_track('test_track', :label => false, :glyph => :generic, :colour => [1,0,0])
  end
  
  def test_feature_creation
    feature = @track.add_feature(Bio::Feature.new('type', '123..456'), :label => 'test_feature')
    assert_equal('test_feature', feature.name)
    assert_equal(123, feature.locations[0].from)
    assert_equal(456, feature.locations[-1].to)
  end
end
