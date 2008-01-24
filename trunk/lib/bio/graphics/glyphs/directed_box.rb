# 
# = bio/graphics/glyphs/directed_box - directed_box glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::DirectedBox < Bio::Graphics::Glyph::Common
    def draw
      if @subfeature.strand == -1 # Reverse strand
        @feature_context.move_to(self.left_pixel + Bio::Graphics::FEATURE_ARROW_LENGTH, 0)
        @feature_context.line_to(self.right_pixel, 0)
        @feature_context.line_to(self.right_pixel, Bio::Graphics::FEATURE_HEIGHT)
        @feature_context.line_to(self.left_pixel + Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT)
        @feature_context.stroke
        open_arrow(@feature_context,:left,self.left_pixel+Bio::Graphics::FEATURE_ARROW_LENGTH,0,Bio::Graphics::FEATURE_ARROW_LENGTH)
      else #default is forward strand
        @feature_context.move_to(self.right_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH, 0)
        @feature_context.line_to(self.left_pixel, 0)
        @feature_context.line_to(self.left_pixel, Bio::Graphics::FEATURE_HEIGHT)
        @feature_context.line_to(self.right_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT)
        open_arrow(@feature_context, :right, self.right_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH, 0, Bio::Graphics::FEATURE_ARROW_LENGTH)
      end
    end
  end
end
