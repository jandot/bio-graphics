# 
# = bio/graphics/subfeature.rb - subfeature class
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
#               Charles Comstock <dgtized@gmail.com>
# License::     The Ruby License
# 

# TODO: Documentation for SubFeature
class Bio::Graphics::Feature::SubFeature
  # !!Not to be used directly.
  # ---
  # *Arguments*:
  # * _feature_ (required) :: Bio::Graphics::Feature
  #   object that this subfeature belongs to
  # * _feature_ _object_ (required) :: A Bio::Feature object (see bioruby)
  # * _glyph_ :: Glyph to use. Default = glyph of the track
  # * _colour_ :: Colour. Default = colour of the track
  # *Returns*:: Bio::Graphics::Feature::SubFeature object
  def initialize(feature, feature_object, glyph = feature.glyph, colour = feature.colour)
    @feature = feature
    @feature_object = feature_object
    @glyph = glyph
    @colour = colour

    @locations = @feature_object.locations

    @start = @locations.collect{|l| l.from}.min.to_i
    @stop = @locations.collect{|l| l.to}.max.to_i
    @strand = @locations[0].strand.to_i
    @pixel_range_collection = Array.new
    @chopped_at_start = false
    @chopped_at_stop = false
    @hidden_subfeatures_at_start = false
    @hidden_subfeatures_at_stop = false

    # Get all pixel ranges for the subfeatures
    @locations.each do |l|
      #   xxxxxx  [          ]
      if l.to < @feature.track.panel.display_start
        @hidden_subfeatures_at_start = true
        next
      #           [          ]   xxxxx
      elsif l.from > @feature.track.panel.display_stop
        @hidden_subfeatures_at_stop = true
        next
      #      xxxx[xxx       ]
      elsif l.from < @feature.track.panel.display_start and l.to > @feature.track.panel.display_start
        start_pixel = 1
        stop_pixel = ( l.to - @feature.track.panel.display_start ).to_f / @feature.track.panel.rescale_factor
        @chopped_at_start = true
      #          [      xxxx]xxxx
      elsif l.from < @feature.track.panel.display_stop and l.to > @feature.track.panel.display_stop
        start_pixel = ( l.from - @feature.track.panel.display_start ).to_f / @feature.track.panel.rescale_factor
        stop_pixel = @feature.track.panel.width
        @chopped_at_stop = true
      #      xxxx[xxxxxxxxxx]xxxx
      elsif l.from < @feature.track.panel.display_start and l.to > @feature.track.panel.display_stop
        start_pixel = 1
        stop_pixel = @feature.track.panel.width
        @chopped_at_start = true
        @chopped_at_stop = true
      #          [   xxxxx  ]
      else
        start_pixel = ( l.from - @feature.track.panel.display_start ).to_f / @feature.track.panel.rescale_factor
        stop_pixel = ( l.to - @feature.track.panel.display_start ).to_f / @feature.track.panel.rescale_factor
      end

      @pixel_range_collection.push(Range.new(start_pixel, stop_pixel))

    end
  end

  # The bioruby Bio::Feature object
  attr_accessor :feature_object

  # The feature that this subfeature belongs to
  attr_accessor :feature

  # The label of the feature
  attr_accessor :label
  alias :name :label

  # The locations of the feature (which is a Bio::Locations object)
  attr_accessor :locations
  alias :location :locations

  # The start position of the feature (in bp)
  attr_accessor :start

  # The stop position of the feature (in bp)
  attr_accessor :stop

  # The strand of the feature
  attr_accessor :strand

  # The glyph to use to draw this (sub)feature
  attr_accessor :glyph

  # The colour to use to draw this (sub)feature
  attr_accessor :colour

  # The array keeping the pixel ranges for the sub-features. Unspliced
  # features will just have one element, while spliced features will
  # have more than one.
  attr_accessor :pixel_range_collection

  # Is the first subfeature incomplete?
  attr_accessor :chopped_at_start

  # Is the last subfeature incomplete?
  attr_accessor :chopped_at_stop

  # Are there subfeatures out of view at the left side of the picture?
  attr_accessor :hidden_subfeatures_at_start

  # Are there subfeatures out of view at the right side of the picture?
  attr_accessor :hidden_subfeatures_at_stop

  # Adds the subfeature to the track cairo context. This method should not 
  # be used directly by the user, but is called by
  # Bio::Graphics::Feature::SubFeature.draw
  # ---
  # *Arguments*:
  # * _track_drawing_ (required) :: the track cairo object
  # *Returns*:: FIXME: I don't know
  def draw(feature_context)
    # Set the glyph to be used. The glyph can be set as a symbol (e.g. :generic)
    # or as a hash (e.g. {'utr' => :line, 'cds' => :directed_spliced}).
    if @feature.glyph.class == Hash
      @glyph = @feature.glyph[@feature_object.feature]
    else
      @glyph = @feature.glyph
    end

    # We have to check if we want to change the glyph type from directed to
    #    undirected
    # There are 2 cases where we don't want to draw arrows on
    # features:
    # (a) when the picture is really zoomed out, features are
    #     so small that the arrow itself is too big
    # (b) if a directed feature on the fw strand extends beyond
    #     the end of the picture, the arrow is out of view. This
    #     is the same as considering the feature as undirected.
    #     The same obviously goes for features on the reverse
    #     strand that extend beyond the left side of the image.
    #
    # (a) Zoomed out
    replace_directed_with_undirected = false
    if (@stop - @start).to_f/@feature.track.panel.rescale_factor.to_f < 2
      replace_directed_with_undirected = true
    end
    # (b) Extending beyond borders picture
    if ( @chopped_at_stop and @strand = 1 ) or ( @chopped_at_start and @strand = -1 )
      replace_directed_with_undirected = true
    end

    local_feature_glyph = nil
    if @glyph == :directed_generic and replace_directed_with_undirected
      local_feature_glyph = :generic
    elsif @glyph == :directed_spliced and replace_directed_with_undirected
      local_feature_glyph = :spliced
    else
      local_feature_glyph = @glyph
    end

    # And draw the thing.

    feature_context.set_source_rgb(@colour)

    case local_feature_glyph
      # triangles are typical for features which have a 1 bp position (start == stop)
      when :triangle
        raise "Start and stop are not the same (necessary if you want triangle glyphs)" if @start != @stop

        # Need to get this for the imagemap
        left_pixel_of_subfeature = @pixel_range_collection[0].lend - Bio::Graphics::FEATURE_ARROW_LENGTH
        right_pixel_of_subfeature = @pixel_range_collection[0].rend + Bio::Graphics::FEATURE_ARROW_LENGTH
        arrow(feature_context,:north,left_pixel_of_subfeature + Bio::Graphics::FEATURE_ARROW_LENGTH, 0, Bio::Graphics::FEATURE_ARROW_LENGTH)
        feature_context.close_path.stroke
      when :dot
        raise "Start and stop are not the same (necessary if you want dot glyphs)" if @start != @stop
        # Need to get this for the imagemap
        radius = Bio::Graphics::FEATURE_HEIGHT/2
        left_pixel_of_subfeature = @pixel_range_collection[0].lend - radius
        right_pixel_of_subfeature = @pixel_range_collection[0].rend + radius
        feature_context.circle(left_pixel_of_subfeature + radius, radius, radius).fill
        feature_context.close_path.stroke
      when :line
        left_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[0].lend
        right_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[-1].rend
        feature_context.move_to(left_pixel_of_subfeature,Bio::Graphics::FEATURE_ARROW_LENGTH)               
        feature_context.line_to(right_pixel_of_subfeature,Bio::Graphics::FEATURE_ARROW_LENGTH)
        feature_context.stroke
      when :line_with_handles
        left_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[0].lend
        right_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[-1].rend
        feature_context.move_to(left_pixel_of_subfeature,Bio::Graphics::FEATURE_ARROW_LENGTH)               
        feature_context.line_to(right_pixel_of_subfeature,Bio::Graphics::FEATURE_ARROW_LENGTH)
        feature_context.stroke

        feature_context.set_source_rgb([0,0,0])
        arrow(feature_context,:right,left_pixel_of_subfeature,0,Bio::Graphics::FEATURE_ARROW_LENGTH)
        feature_context.close_path.stroke              
        arrow(feature_context,:left,right_pixel_of_subfeature,0,Bio::Graphics::FEATURE_ARROW_LENGTH)
        feature_context.close_path.stroke

        feature_context.set_source_rgb(@colour)
    when :directed_generic
        # Need to get this for the imagemap
        left_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[0].lend
        right_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[-1].rend
        if self.strand == -1 # Reverse strand
          feature_context.rectangle(left_pixel_of_subfeature+Bio::Graphics::FEATURE_ARROW_LENGTH, 0, right_pixel_of_subfeature - left_pixel_of_subfeature - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT).fill
          arrow(feature_context,:left,left_pixel_of_subfeature+Bio::Graphics::FEATURE_ARROW_LENGTH,0,Bio::Graphics::FEATURE_ARROW_LENGTH)
          feature_context.close_path.fill
        else #default is forward strand
          feature_context.rectangle(left_pixel_of_subfeature, 0, right_pixel_of_subfeature - left_pixel_of_subfeature - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT).fill
          arrow(feature_context,:right,right_pixel_of_subfeature-Bio::Graphics::FEATURE_ARROW_LENGTH,0,Bio::Graphics::FEATURE_ARROW_LENGTH)
          feature_context.close_path.fill
        end
      when :spliced
        # Need to get this for the imagemap
        left_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[0].lend
        right_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[-1].rend

        pixel_ranges = @pixel_range_collection.sort_by{|pr| pr.lend}
        draw_spliced(feature_context, pixel_ranges, [], [])
      when :directed_spliced
        gap_starts = Array.new
        gap_stops = Array.new

        # Need to get this for the imagemap
        left_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[0].lend
        right_pixel_of_subfeature = @pixel_range_collection.sort_by{|pr| pr.lend}[-1].rend

        #   Start with the one with the arrow
        pixel_ranges = @pixel_range_collection.sort_by{|pr| pr.lend}
        range_with_arrow = nil
        if @strand == -1 # reverse strand => box with arrow is first one
          range_with_arrow = pixel_ranges.shift
          feature_context.rectangle((range_with_arrow.lend)+Bio::Graphics::FEATURE_ARROW_LENGTH, 0, range_with_arrow.rend - range_with_arrow.lend - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT).fill
          arrow(feature_context,:left,range_with_arrow.lend+Bio::Graphics::FEATURE_ARROW_LENGTH, 0,Bio::Graphics::FEATURE_ARROW_LENGTH)
          feature_context.close_path.fill
        else # forward strand => box with arrow is last one
          range_with_arrow = pixel_ranges.pop
          feature_context.rectangle(range_with_arrow.lend, 0, range_with_arrow.rend - range_with_arrow.lend - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT).fill
          arrow(feature_context,:right,range_with_arrow.rend-Bio::Graphics::FEATURE_ARROW_LENGTH, 0,Bio::Graphics::FEATURE_ARROW_LENGTH)
          feature_context.close_path.fill
        end
        gap_starts.push(range_with_arrow.rend)
        gap_stops.push(range_with_arrow.lend)

        #   And then add the others
        draw_spliced(feature_context, pixel_ranges, gap_starts, gap_stops)
      else #treat as 'generic'
        left_pixel_of_subfeature, right_pixel_of_subfeature = @pixel_range_collection[0].lend, @pixel_range_collection[-1].rend
        feature_context.rectangle(left_pixel_of_subfeature, 0, (right_pixel_of_subfeature - left_pixel_of_subfeature), Bio::Graphics::FEATURE_HEIGHT).fill
    end
    @feature.left_pixel_of_subfeatures.push(left_pixel_of_subfeature)
    @feature.right_pixel_of_subfeatures.push(right_pixel_of_subfeature)

  end

  private

  # Method to draw each of the squared spliced rectangles for
  # spliced and directed_spliced
  # ---
  # *Arguments*:
  # * _track_drawing_::
  # * _pixel_ranges_:: 
  # * _top_pixel_of_feature_:: 
  # * _gap_starts_:: 
  # * _gap_stops_:: 
  def draw_spliced(feature_context, pixel_ranges, gap_starts, gap_stops)            
    # draw the parts
    pixel_ranges.each do |range|
      feature_context.rectangle(range.lend, 0, range.rend - range.lend, Bio::Graphics::FEATURE_HEIGHT).fill
      gap_starts.push(range.rend)
      gap_stops.push(range.lend)
    end

    # And then draw the connections in the gaps
    # Start with removing the very first start and the very last stop.
    gap_starts.sort!.pop
    gap_stops.sort!.shift

    gap_starts.length.times do |gap_number|
      connector(feature_context,gap_starts[gap_number].to_f,gap_stops[gap_number].to_f)
    end

    if @hidden_subfeatures_at_stop
      from = @pixel_range_collection.sort_by{|pr| pr.lend}[-1].rend
      to = @feature.track.panel.width
      feature_context.move_to(from, Bio::Graphics::FEATURE_ARROW_LENGTH)
      feature_context.line_to(to, Bio::Graphics::FEATURE_ARROW_LENGTH)
      feature_context.stroke
    end

    if @hidden_subfeatures_at_start
      from = 1
      to = @pixel_range_collection.sort_by{|pr| pr.lend}[0].lend
      feature_context.move_to(from, Bio::Graphics::FEATURE_ARROW_LENGTH)
      feature_context.line_to(to, Bio::Graphics::FEATURE_ARROW_LENGTH)
      feature_context.stroke
    end
  end

  # Method to draw the arrows of directed glyphs. Not to be used
  # directly, but called by Feature#draw.
  def arrow(feature_context,direction,x,y,size)
    case direction
    when :right
      feature_context.move_to(x,y)
      feature_context.rel_line_to(size,size)
      feature_context.rel_line_to(-size,size)
      feature_context.close_path.fill
    when :left
      feature_context.move_to(x,y)
      feature_context.rel_line_to(-size,size)
      feature_context.rel_line_to(size,size)
      feature_context.close_path.fill
    when :north
      feature_context.move_to(x-size,y+size)
      feature_context.rel_line_to(size,-size)
      feature_context.rel_line_to(size,size)
      feature_context.close_path.fill
    when :south
      feature_context.move_to(x-size,y-size)
      feature_context.rel_line_to(size,size)
      feature_context.rel_line_to(size,-size)
      feature_context.close_path.fill
    end
  end

  # Method to draw the connections (introns) of spliced glyphs. Not to
  # be used directly, but called by Feature#draw.
  def connector(feature_context,from,to)
    line_width = feature_context.line_width
    feature_context.set_line_width(0.5)
    middle = from + ((to - from)/2)
    feature_context.move_to(from, 2)
    feature_context.line_to(middle, 7)
    feature_context.line_to(to, 2)
    feature_context.stroke
    feature_context.set_line_width(line_width)
  end                    
end #SubFeature
