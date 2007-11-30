module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::CustomTestGlyphInFile < Bio::Graphics::Glyph::Common
    
    def draw
      (self.left_pixel..self.right_pixel).step(20) do |pos|
        @feature_context.move_to(pos, 0)
        @feature_context.line_to(pos, Bio::Graphics::FEATURE_HEIGHT)
        @feature_context.close_path.stroke
      end
    end
  end
end