# 
# = bio/graphics/glyphs/box - box glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Box < Bio::Graphics::Glyph::Common
    def draw
      @feature_context.move_to(self.left_pixel, 0)
      @feature_context.line_to(self.right_pixel, 0)
      @feature_context.line_to(self.right_pixel, Bio::Graphics::FEATURE_HEIGHT)
      @feature_context.line_to(self.left_pixel, Bio::Graphics::FEATURE_HEIGHT)
      @feature_context.close_path
      @feature_context.stroke

    end
  end
end
