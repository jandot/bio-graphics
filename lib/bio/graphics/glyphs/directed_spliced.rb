# 
# = bio/graphics/glyphs/directed_spliced - directed_spliced glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::DirectedSpliced < Bio::Graphics::Glyph::Common
    def draw
      gap_starts = Array.new
      gap_stops = Array.new

      #   Start with the one with the arrow
      pixel_ranges = @subfeature.pixel_range_collection.sort_by{|pr| pr.lend}
      range_with_arrow = nil
      if @subfeature.strand == -1 # reverse strand => box with arrow is first one
        range_with_arrow = pixel_ranges.shift
        @feature_context.rectangle((range_with_arrow.lend)+Bio::Graphics::FEATURE_ARROW_LENGTH, 0, range_with_arrow.rend - range_with_arrow.lend - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT).fill
        arrow(@feature_context,:left,range_with_arrow.lend+Bio::Graphics::FEATURE_ARROW_LENGTH, 0,Bio::Graphics::FEATURE_ARROW_LENGTH)
        @feature_context.close_path.fill
      else # forward strand => box with arrow is last one
        range_with_arrow = pixel_ranges.pop
        @feature_context.rectangle(range_with_arrow.lend, 0, range_with_arrow.rend - range_with_arrow.lend - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT).fill
        arrow(@feature_context,:right,range_with_arrow.rend-Bio::Graphics::FEATURE_ARROW_LENGTH, 0,Bio::Graphics::FEATURE_ARROW_LENGTH)
        @feature_context.close_path.fill
      end
      gap_starts.push(range_with_arrow.rend)
      gap_stops.push(range_with_arrow.lend)

      #   And then add the others
      draw_spliced(@feature_context, pixel_ranges, gap_starts, gap_stops)

    end
  end
end


