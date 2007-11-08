require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/bio-graphics'

class TestPanel < Test::Unit::TestCase
  def test_panel_creation
    panel = Bio::Graphics::Panel.new(1000, 500, false, 0, 1000)
    assert_equal(1000, panel.length)
    assert_equal(500, panel.width)
    assert_equal(false, panel.clickable)
    assert_equal(0, panel.display_start)
    assert_equal(1000, panel.display_stop)
    assert_equal(1000/500, panel.rescale_factor)
    assert_equal(0, panel.tracks.length)
  end
  
  def test_panel_creation_out_of_boundaries
    panel = Bio::Graphics::Panel.new(1000, 500, false, -7, 5000)
    assert_same(0, panel.display_start)
    assert_same(1000, panel.display_stop)
  end
  
end

class TestTrack < Test::Unit::TestCase
	def setup
    @panel = Bio::Graphics::Panel.new(1000, 500, false, 0, 1000)
  end

  def test_track_creation
    track = @panel.add_track('test_track', false, [1,0,0], 'generic')
    assert_equal('test_track', track.name)
    assert_equal([1,0,0], track.colour)
    assert_equal('generic', track.glyph)
    assert_equal(1, @panel.tracks.length)
    assert_equal(0, track.features.length)
  end
end

class TestFeature < Test::Unit::TestCase
  def setup
    @panel = Bio::Graphics::Panel.new(1000, 500, false, 0, 1000)
    @track = @panel.add_track('test_track', false, [1,0,0], 'generic')
  end
  
  def test_feature_creation
    feature = @track.add_feature(Bio::Feature.new('type', '123..456'), 'test_feature')
    assert_equal('test_feature', feature.name)
    assert_equal(123, feature.locations[0].from)
    assert_equal(456, feature.locations[-1].to)
  end
end
