module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Spliced < Bio::Graphics::Glyph::Common
    def draw
      pixel_ranges = @subfeature.pixel_range_collection.sort_by{|pr| pr.lend}
      draw_spliced(@feature_context, pixel_ranges, [], [])
    end
  end
end
