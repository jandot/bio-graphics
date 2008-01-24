# 
# = bio/graphics/glyphs/dot - dot glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Dot < Bio::Graphics::Glyph::Common
    attr_accessor :radius
    
    def draw
      raise "Start and stop are not the same (necessary if you want triangle glyphs)" if @subfeature.start != @subfeature.stop
      
      @radius = Bio::Graphics::FEATURE_HEIGHT/2
      @feature_context.circle(self.left_pixel + @radius, @radius, @radius).fill
      @feature_context.close_path.stroke
    end
  end
end