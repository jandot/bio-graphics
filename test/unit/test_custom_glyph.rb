require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/bio-graphics'

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::CustomTestGlyph < Bio::Graphics::Glyph::Common
    
    def draw
      @feature_context.move_to(self.left_pixel,0)
      @feature_context.line_to(self.right_pixel,Bio::Graphics::FEATURE_HEIGHT)
      @feature_context.move_to(self.right_pixel,0)
      @feature_context.line_to(self.left_pixel,Bio::Graphics::FEATURE_HEIGHT)
      @feature_context.close_path.stroke
    end
  end
end

class TestCustomGlyph < Test::Unit::TestCase
  def test_draw
    panel = Bio::Graphics::Panel.new(500, :width => 250, :clickable => false,
                                     :display_range => 0..1000)
    track = panel.add_track('test_track', :label => false, :glyph => :custom_test_glyph, :colour => [0,0,1])
    track.add_feature(Bio::Feature.new('type', '123..456'), :label => 'test_feature')
    
    panel.draw('output.png')
    system("display output.png & sleep 2 && kill $!")
    File.delete('output.png')
  end
end

class TestCustomGlyphInFile < Test::Unit::TestCase
  def setup
    system("cp custom_glyph_in_file.rb ../../lib/bio/graphics/glyphs/")
    require File.dirname(__FILE__) + '/../../lib/bio/graphics/glyphs/custom_glyph_in_file.rb'
  end
  
  def test_draw
    panel = Bio::Graphics::Panel.new(500, :width => 250, :clickable => false,
                                     :display_range => 0..1000)
    track = panel.add_track('test_track', :label => false, :glyph => :custom_test_glyph_in_file, :colour => [0,0,1])
    track.add_feature(Bio::Feature.new('type', '123..456'), :label =>'test_feature')

    panel.draw('output.png')
    system("display output.png & sleep 2 && kill $!")
    File.delete('output.png')
  end
  
  def teardown
    File.delete(File.dirname(__FILE__) + '/../../lib/bio/graphics/glyphs/custom_glyph_in_file.rb')
  end
end