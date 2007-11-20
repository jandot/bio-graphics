# 
# = bio/graphics/feature.rb - feature class
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
# 

# The Bio::Graphics::Track::Feature class describes features to be
# placed on the graph. See Bio::Graphics documentation for explanation
# of interplay between different classes.
#
# The position of the Feature is a Bio::Locations object to make it possible
# to transparently work with simple and spliced features.
#
# The Bio::Graphics::Track::Feature class inherits from Bio::Feature.
class Bio::Graphics::Panel::Track::Feature
  # !!Not to be used directly. Use
  # Bio::Graphics::Panel::Track.add_feature instead!!
  # A feature can not exist except within the confines of a
  # Bio::Graphics::Panel::Track object.
  #
  #--
  # This is necessary because the feature needs to know the colour and glyph,
  # both of which are defined within the panel.
  #++
  #
  # ---
  # *Arguments*:
  # * _track_ (required) :: Bio::Graphics::Panel::Track object that this
  #   feature belongs to
  # * _feature_ _object_ (required) :: A Bio::Feature object (see bioruby)
  # * _label_ :: Label of the feature. Default = 'anonymous'
  # * _link_ :: URL for clickable images. Default = nil
  # * _glyph_ :: Glyph to use. Default = glyph of the track
  # * _colour_ :: Colour. Default = colour of the track
  # *Returns*:: Bio::Graphics::Track::Feature object
  def initialize(track, feature_object, label = 'anonymous', link = nil, glyph = track.glyph, colour = track.colour)
    @track = track
    @feature_object = feature_object
    @label = label
    @link = link
    @glyph = glyph
    @colour = colour

    @locations = @feature_object.locations

    @start = @locations.collect{|l| l.from}.min.to_i
    @stop = @locations.collect{|l| l.to}.max.to_i

    # Create Bio::Graphics SubFeatures
    # The drawing is handled by subfeatures. If there are no defined, the
    # subfeatures array will just hold one element: the @feature_object of
    # self.
    @subfeatures = Array.new
    if ! @feature_object.subfeatures.empty?
      @feature_object.subfeatures.each do |subfeature|
        @subfeatures.push(Bio::Graphics::Panel::Track::Feature::SubFeature.new(self, subfeature, @glyph, @colour))
      end
    else
      @subfeatures.push(Bio::Graphics::Panel::Track::Feature::SubFeature.new(self, @feature_object, @glyph, @colour))
    end

    @left_pixel_of_subfeatures = Array.new
    @right_pixel_of_subfeatures = Array.new
  end

  # The bioruby Bio::Feature object
  attr_accessor :feature_object

  attr_accessor :locations

  # The Bio::Graphics SubFeatures
  attr_accessor :subfeatures

  # The track that this feature belongs to
  attr_accessor :track

  # The label of the feature
  attr_accessor :label
  alias :name :label

  # The URL to be followed when the glyph for this feature is clicked
  attr_accessor :link

  # The glyph to use to draw this (sub)feature
  attr_accessor :glyph

  # The colour to use to draw this (sub)feature
  attr_accessor :colour

  attr_accessor :start, :stop
  attr_accessor :left_pixel_of_feature, :top_pixel_of_feature
  attr_accessor :left_pixel_of_subfeatures, :right_pixel_of_subfeatures

  # Adds the feature to the track cairo context. This method should not 
  # be used directly by the user, but is called by
  # Bio::Graphics::Panel::Track.draw
  # ---
  # *Arguments*:
  # * _track_drawing_ (required) :: the track cairo object
  # *Returns*:: FIXME: I don't know
  def draw(track_drawing)
    row = self.find_row
    @top_pixel_of_feature = Bio::Graphics::FEATURE_V_DISTANCE + (Bio::Graphics::FEATURE_HEIGHT+Bio::Graphics::FEATURE_V_DISTANCE)*row
    bottom_pixel_of_feature = @top_pixel_of_feature + Bio::Graphics::FEATURE_HEIGHT

    # Let the subfeatures do the drawing.
    @subfeatures.each do |subfeature|
      subfeature.draw(track_drawing)
    end

    @left_pixel_of_feature = @left_pixel_of_subfeatures.min
    @right_pixel_of_feature = @right_pixel_of_subfeatures.max

    # Add the label for the feature
    if @track.show_label
      pango_layout = track_drawing.create_pango_layout
      pango_layout.text = @label
      fdesc = Pango::FontDescription.new('Sans Serif')
      fdesc.set_size(8 * Pango::SCALE)
      pango_layout.font_description = fdesc

      text_range = @start.floor..(@start.floor + pango_layout.pixel_size[0]*@track.panel.rescale_factor)
      if @track.grid[row+1].nil?
        @track.grid[row+1] = Array.new
      end
      @track.grid[row].push(text_range)
      @track.grid[row+1].push(text_range)
      track_drawing.move_to(@left_pixel_of_feature, @top_pixel_of_feature + Bio::Graphics::TRACK_HEADER_HEIGHT)
      track_drawing.set_source_rgb(0,0,0)
      track_drawing.show_pango_layout(pango_layout)
      track_drawing.set_source_rgb(@colour)
    end


    # And add the region to the image map
    if @track.panel.clickable
      # Comment: we have to add the vertical_offset and TRACK_HEADER_HEIGHT!
      @track.panel.image_map.elements.push(ImageMap::ImageMapElement.new(@left_pixel_of_feature,
                                                                         @top_pixel_of_feature + @track.vertical_offset + Bio::Graphics::TRACK_HEADER_HEIGHT,
                                                                         @right_pixel_of_feature,
                                                                         bottom_pixel_of_feature + @track.vertical_offset + Bio::Graphics::TRACK_HEADER_HEIGHT,
                                                                         @link
                                                                         ))
    end
  end

  # Calculates the row within the track where this feature should be
  # drawn. This method should not 
  # be used directly by the user, but is called by
  # Bio::Graphics::Panel::Track::Feature.draw
  # ---
  # *Arguments*:: none
  # *Returns*:: row number
  def find_row
    row_found = false

    # We've got to find out what row to draw the feature on. If two 
    # features overlap, one of them has to be 'bumped' down. So we'll
    # first try to draw a new feature at the top of the track. If
    # it however would overlap with another one, we'll bump it down
    # to the next row.
    feature_range = (@start.floor - 1..@stop.ceil + 1)
    row = 1
    row_available = true
    until row_found
      if ! @track.grid[row].nil?
        @track.grid[row].each do |covered|
          if feature_range.include?(covered.first) or covered.include?(feature_range.first)
            row_available = false
          end
        end
        if ! @track.grid[row+1].nil? #Still have to check if there is no label there.
          @track.grid[row+1].each do |covered|
            if feature_range.include?(covered.first) or covered.include?(feature_range.first)
              row_available = false
            end
          end
        end
      end

      if ! row_available
        row += 1
        row_available = true
      else # We've found the place where to draw the feature.
        if @track.grid[row].nil?
          @track.grid[row] = Array.new
        end
        @track.grid[row].push(feature_range)
        row_found = true
      end
    end
    return row
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
  def draw_spliced(track_drawing, pixel_ranges, top_pixel_of_feature, gap_starts, gap_stops)            
    # draw the parts
    pixel_ranges.each do |range|
      track_drawing.rectangle(range.lend, top_pixel_of_feature, range.rend - range.lend, Bio::Graphics::FEATURE_HEIGHT).fill
      gap_starts.push(range.rend)
      gap_stops.push(range.lend)
    end

    # And then draw the connections in the gaps
    # Start with removing the very first start and the very last stop.
    gap_starts.sort!.pop
    gap_stops.sort!.shift

    gap_starts.length.times do |gap_number|
      connector(track_drawing,gap_starts[gap_number].to_f,gap_stops[gap_number].to_f,top_pixel_of_feature)
    end

    if @hidden_subfeatures_at_stop
      from = @pixel_range_collection.sort_by{|pr| pr.lend}[-1].rend
      to = @track.panel.width
      track_drawing.move_to(from, top_pixel_of_feature+Bio::Graphics::FEATURE_ARROW_LENGTH)
      track_drawing.line_to(to, top_pixel_of_feature+Bio::Graphics::FEATURE_ARROW_LENGTH)
      track_drawing.stroke
    end

    if @hidden_subfeatures_at_start
      from = 1
      to = @pixel_range_collection.sort_by{|pr| pr.lend}[0].lend
      track_drawing.move_to(from, top_pixel_of_feature+Bio::Graphics::FEATURE_ARROW_LENGTH)
      track_drawing.line_to(to, top_pixel_of_feature+Bio::Graphics::FEATURE_ARROW_LENGTH)
      track_drawing.stroke
    end
  end

  # Method to draw the arrows of directed glyphs. Not to be used
  # directly, but called by Feature#draw.
  def arrow(track,direction,x,y,size)
    case direction
    when :right
      track.move_to(x,y)
      track.rel_line_to(size,size)
      track.rel_line_to(-size,size)
      track.close_path.fill
    when :left
      track.move_to(x,y)
      track.rel_line_to(-size,size)
      track.rel_line_to(size,size)
      track.close_path.fill
    when :north
      track.move_to(x-size,y+size)
      track.rel_line_to(size,-size)
      track.rel_line_to(size,size)
      track.close_path.fill
    when :south
      track.move_to(x-size,y-size)
      track.rel_line_to(size,size)
      track.rel_line_to(size,-size)
      track.close_path.fill
    end
  end

  # Method to draw the connections (introns) of spliced glyphs. Not to
  # be used directly, but called by Feature#draw.
  def connector(track,from,to,top)
    line_width = track.line_width
    track.set_source_rgb([0,0,0])
    track.set_line_width(0.5)
    middle = from + ((to - from)/2)
    track.move_to(from, top+2)
    track.line_to(middle, top+7)
    track.line_to(to, top+2)
    track.stroke
    track.set_line_width(line_width)
    track.set_source_rgb(@colour)
  end                    
end #Feature
