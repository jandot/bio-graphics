# 
# = bio/graphics/glyphs/generic - generic glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Generic < Bio::Graphics::Glyph::Common
    def draw
      @feature_context.rectangle(self.left_pixel, 0, (self.right_pixel - self.left_pixel), Bio::Graphics::FEATURE_HEIGHT).fill
    end
  end
end
