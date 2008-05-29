# 
# = bio/graphics/glyphs/line_with_handles - line_with_handles glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::LineWithHandles < Bio::Graphics::Glyph::Common
    def draw
      @feature_context.move_to(self.left_pixel,Bio::Graphics::FEATURE_ARROW_LENGTH)               
      @feature_context.line_to(self.right_pixel,Bio::Graphics::FEATURE_ARROW_LENGTH)
      @feature_context.stroke

      @feature_context.set_source_rgb([0,0,0])
      arrow(@feature_context,:right,self.left_pixel,0,Bio::Graphics::FEATURE_ARROW_LENGTH)
      @feature_context.close_path.stroke              
      arrow(@feature_context,:left,self.right_pixel,0,Bio::Graphics::FEATURE_ARROW_LENGTH)
      @feature_context.close_path.stroke

      @feature_context.set_source_rgb(@subfeature.colour)
    end
  end
end
