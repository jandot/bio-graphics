# 
# = bio/graphics/glyphs/directed_generic - directed_generic glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::DirectedGeneric < Bio::Graphics::Glyph::Common
    def draw
      if @subfeature.strand == -1 # Reverse strand
        @feature_context.rectangle(self.left_pixel+Bio::Graphics::FEATURE_ARROW_LENGTH, 0, self.right_pixel - self.left_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT).fill
        arrow(@feature_context,:left,self.left_pixel+Bio::Graphics::FEATURE_ARROW_LENGTH,0,Bio::Graphics::FEATURE_ARROW_LENGTH)
        @feature_context.close_path.fill
      else #default is forward strand
        @feature_context.rectangle(self.left_pixel, 0, self.right_pixel- self.left_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT).fill
        arrow(@feature_context,:right,self.right_pixel-Bio::Graphics::FEATURE_ARROW_LENGTH,0,Bio::Graphics::FEATURE_ARROW_LENGTH)
        @feature_context.close_path.fill
      end
    end
  end
end
