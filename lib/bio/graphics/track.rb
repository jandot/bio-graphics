# 
# = bio/graphics/track - track class
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
module Bio
  module Graphics
    class Panel
      # The Bio::Graphics::Track class describes the container for features of
      # the same type. See Bio::Graphics documentation for explanation of
      # interplay between different classes.
      class Track
        # !!Not to be used directly. Use Bio::Graphics::Panel.add_track instead!!
        # A track can not exist except within the confines of a
        # Bio::Graphics::Panel object.
        #
        #--
        # This is necessary because the track needs to know the rescale_factor
        # and width of the picture, both of which are defined within the panel.
        #++
        #
        # ---
        # *Arguments*:
        # * _panel_ (required) :: Bio::Graphics::Panel object that this track
        #   belongs to
        # * _name_ (required) :: Name of the track to be displayed (e.g. 'genes')
        # * _colour_ :: Colour to be used to draw the features within the track.
        #   Default = 'blue'
        # * _glyph_ :: Glyph to use for drawing the features. Options are:
        #   'generic', 'directed_generic', 'spliced, 'directed_spliced' and
        #   'triangle'. Triangles can be used
        #   for features whose start and stop positions are the same (e.g. SNPs).
        #   If you try to draw a feature that is longer with triangles, an error
        #   will be shown.
        # *Returns*:: Bio::Graphics::Track object
        def initialize(panel, name, feature_colour = [0,0,1], feature_glyph = 'generic')
          @panel = panel
          @name = name
          @feature_colour = feature_colour
          @feature_glyph = feature_glyph
          @features = Array.new
          @number_of_times_bumped = 0
        end
        attr_accessor :panel, :name, :feature_colour, :feature_glyph, :features, :number_of_times_bumped, :height

        # Adds a Bio::Graphics::Panel::Track::Feature to this track. A track contains
        # features of the same type, e.g. (for sequence annotation:) genes,
        # polymorphisms, ESTs, etc.
        #
        #  est_track.add_feature('EST1','50..60')
        #  est_track.add_feature('EST2','52..73')
        #  est_track.add_feature('EST3','41..69')
        #  gene_track.add_feature('gene2','39..73')
        #
        # For spliced features:
        #  est_track.add_feature('EST4','join(34..53,153..191)')
        #
        # Or on the complement strand:
        #  est_track.add_feature('EST5','complement(join(34..53,153..191))')
        #
        # See the documentation in Bio::Locations for a full description of
        # how locations can be defined.
        #
        # Features are only added if they are at least partly in the displayed
        # region. If a feature is completely outside of the region, it's not
        # added. If it should be only partly visible, it is added completely.
        #
        # ---
        # *Arguments*:
        # * _name_ (required) :: Name of the feature
        # * _location_ :: String. Default: whole of panel, forward strand.
        # * _link_ :: URL to link to for this glyph
        # *Returns*:: Bio::Graphics::Track::Feature object that was created or nil
        def add_feature(name, location_string = '0..' + (@panel.width * @panel.rescale_factor).to_s, link = nil)
          if link == ''
            link = nil
          end
          location_object = Bio::Locations.new(location_string)
          start = location_object.collect{|l| l.from}.min.to_i
          stop = location_object.collect{|l| l.to}.max.to_i

          #if start < 0 or stop > (panel.width.to_f * panel.rescale_factor.to_f).to_i
          #  raise "ERROR: feature " + name + " has coordinates that lie outside of panel"
          #end
          #@features.push(Bio::Graphics::Panel::Track::Feature.new(self, name, location_object, link))
          #return @features[-1]

          if stop < panel.display_start or start > panel.display_stop
            return nil
          else #elsif start >= panel.display_start and stop <= panel.display_stop
            @features.push(Bio::Graphics::Panel::Track::Feature.new(self, name, location_object, link))
            return @features[-1]
          # TODO: chop bits of that extend beyond display
          #elsif ( start >= panel.display_start and stop > panel.display_stop ) #Feature extends beyond right border
          #  new_location_object = Bio::Locations.new
          #  location_object.each do |l|
          #    if l.to <= panel.display_stop
          #      new_location_object.push(Bio::Location.new('l
          #    end
          end
        end


        # Adds the track to a cairo drawing. This method should not be used
        # directly by the user, but is called by Bio::Graphics::Panel.draw
        # ---
        # *Arguments*:
        # * _paneldrawing_ (required) :: the panel cairo object
        # * _verticaloffset_ (required) :: number of pixels to offset the track downwards,
        #   based on the height of other tracks that were drawn above it
        # *Returns*:: FIXME: I don't know
        def draw(panel_drawing, vertical_offset)
          track_drawing = Cairo::Context.new(panel_drawing)

          # Draw thin line above title
          track_drawing.set_source_rgb(0.75,0.75,0.75)
          track_drawing.move_to(0, vertical_offset)
          track_drawing.line_to(panel.width, vertical_offset)
          track_drawing.stroke

          # Draw track title
          track_drawing.set_source_rgb(0,0,0)
          track_drawing.select_font_face('Georgia',1,1)
          track_drawing.set_font_size(TRACK_HEADER_HEIGHT)
          track_drawing.move_to(0,TRACK_HEADER_HEIGHT + vertical_offset + 10)
          track_drawing.show_text(self.name)

          # Draw the features
          grid = Hash.new

          track_drawing.save do
            track_drawing.translate(0, vertical_offset + TRACK_HEADER_HEIGHT)
            track_drawing.set_source_rgb(@feature_colour)

            # Now draw the features
            @features.each do |feature|
              if feature.stop <= self.panel.display_start or feature.start >= self.panel.display_stop
                next
              else
                
                feature_drawn = false
                feature_range = (feature.start.floor..feature.stop.ceil)
                row = 1
                row_available = true
                until feature_drawn
                  if ! grid[row].nil?
                    grid[row].each do |covered|
                      if feature_range.include?(covered.first) or covered.include?(feature_range.first)
                        row_available = false
                      end
                    end
                  end
  
                  if ! row_available
                    row += 1
                    row_available = true
                  else
                    if grid[row].nil?
                      grid[row] = Array.new
                    end
                    grid[row].push(feature_range)

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
                    if (feature.stop - feature.start).to_f/panel.rescale_factor.to_f < 2
                      replace_directed_with_undirected = true
                    end
                    # (b) Extending beyond borders picture
                    if ( feature.chopped_at_stop and feature.strand = 1 ) or ( feature.chopped_at_start and feature.strand = -1 )
                      replace_directed_with_undirected = true
                    end

                    local_feature_glyph = nil
                    if feature_glyph == 'directed_generic' and replace_directed_with_undirected
                      local_feature_glyph = 'generic'
                    elsif feature_glyph == 'directed_spliced' and replace_directed_with_undirected
                      local_feature_glyph = 'spliced'
                    else
                      local_feature_glyph = feature_glyph
                    end
  
                    top_pixel_of_feature = FEATURE_V_DISTANCE + (FEATURE_HEIGHT+FEATURE_V_DISTANCE)*row
                    bottom_pixel_of_feature = top_pixel_of_feature + FEATURE_HEIGHT
  
                    case local_feature_glyph
                      # triangles are typical for features which have a 1 bp position (start == stop)
                      when 'triangle'
                        raise "Start and stop are not the same (necessary if you want triangle glyphs)" if feature.start != feature.stop
  
                        # Need to get this for the imagemap
                        left_pixel_of_feature = feature.pixel_range_collection[0].start_pixel - 3
                        right_pixel_of_feature = feature.pixel_range_collection[0].stop_pixel + 3
                        track_drawing.move_to(left_pixel_of_feature + 3, top_pixel_of_feature)
                        track_drawing.rel_line_to(-3, FEATURE_HEIGHT)
                        track_drawing.rel_line_to(6, 0)
                        track_drawing.close_path.fill
  
                      when 'directed_generic'
                        # Need to get this for the imagemap
                        left_pixel_of_feature = feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                        right_pixel_of_feature = feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
                        if feature.strand == -1 # Reverse strand
                          # Draw main box
                          track_drawing.rectangle(left_pixel_of_feature+FEATURE_ARROW_LENGTH, top_pixel_of_feature, right_pixel_of_feature - left_pixel_of_feature - FEATURE_ARROW_LENGTH, FEATURE_HEIGHT).fill
  
                          # Draw arrow
                          track_drawing.move_to(left_pixel_of_feature+FEATURE_ARROW_LENGTH, top_pixel_of_feature)
                          track_drawing.rel_line_to(-FEATURE_ARROW_LENGTH, FEATURE_HEIGHT/2)
                          track_drawing.rel_line_to(FEATURE_ARROW_LENGTH, FEATURE_HEIGHT/2)
                          track_drawing.close_path.fill
  
                        else #default is forward strand
                          track_drawing.rectangle(left_pixel_of_feature, top_pixel_of_feature, right_pixel_of_feature - left_pixel_of_feature - FEATURE_ARROW_LENGTH, FEATURE_HEIGHT).fill
                          track_drawing.move_to(right_pixel_of_feature - FEATURE_ARROW_LENGTH, top_pixel_of_feature)
                          track_drawing.rel_line_to(FEATURE_ARROW_LENGTH, FEATURE_HEIGHT/2)
                          track_drawing.rel_line_to(-FEATURE_ARROW_LENGTH, FEATURE_HEIGHT/2)
                          track_drawing.close_path.fill
                        end
                      when 'spliced'
                        gap_starts = Array.new
                        gap_stops = Array.new
  
                        # Need to get this for the imagemap
                        left_pixel_of_feature = feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                        right_pixel_of_feature = feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
  
                        # First draw the parts
                        feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}.each do |pr|
                          track_drawing.rectangle(pr.start_pixel, top_pixel_of_feature, (pr.stop_pixel - pr.start_pixel), FEATURE_HEIGHT).fill
                          gap_starts.push(pr.stop_pixel)
                          gap_stops.push(pr.start_pixel)
                        end
  
                        # And then draw the connections in the gaps
                        # Start with removing the very first start and the very last stop.
                        gap_starts.sort!.pop
                        gap_stops.sort!.shift
  
                        gap_starts.length.times do |gap_number|
                          from = gap_starts[gap_number].to_f
                          to = gap_stops[gap_number].to_f
                          middle = from + ((to - from)/2)
                          track_drawing.move_to(from, top_pixel_of_feature+2)
                          track_drawing.line_to(middle, top_pixel_of_feature+7)
                          track_drawing.line_to(to, top_pixel_of_feature+2)
                          track_drawing.stroke
                        end
                        
                        if feature.hidden_subfeatures_at_stop
                          from = feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
                          to = panel.width
                          track_drawing.move_to(from, top_pixel_of_feature+5)
                          track_drawing.line_to(to, top_pixel_of_feature+5)
                          track_drawing.stroke
                        end
                        
                        if feature.hidden_subfeatures_at_start
                          from = 1
                          to = feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                          track_drawing.move_to(from, top_pixel_of_feature+5)
                          track_drawing.line_to(to, top_pixel_of_feature+5)
                          track_drawing.stroke
                        end
  
                      when 'directed_spliced'
                        gap_starts = Array.new
                        gap_stops = Array.new
                        # First draw the parts
                        locations = feature.location.sort_by{|l| l.from}
  
                        # Need to get this for the imagemap
                        left_pixel_of_feature = feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                        right_pixel_of_feature = feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
  
                        #   Start with the one with the arrow
                        pixel_ranges = feature.pixel_range_collection.sort_by{|pr| pr.start_pixel}
                        range_with_arrow = nil
                        if feature.strand == -1 # reverse strand => box with arrow is first one
                          range_with_arrow = pixel_ranges.shift
                          track_drawing.rectangle((range_with_arrow.start_pixel)+FEATURE_ARROW_LENGTH, top_pixel_of_feature, range_with_arrow.stop_pixel - range_with_arrow.start_pixel, FEATURE_HEIGHT).fill
                          track_drawing.move_to(range_with_arrow.start_pixel+FEATURE_ARROW_LENGTH, top_pixel_of_feature)
                          track_drawing.rel_line_to(-FEATURE_ARROW_LENGTH, FEATURE_HEIGHT/2)
                          track_drawing.rel_line_to(FEATURE_ARROW_LENGTH, FEATURE_HEIGHT/2)
                          track_drawing.close_path.fill
                        else # forward strand => box with arrow is last one
                          range_with_arrow = pixel_ranges.pop
                          track_drawing.rectangle(range_with_arrow.start_pixel-FEATURE_ARROW_LENGTH, top_pixel_of_feature, range_with_arrow.stop_pixel - range_with_arrow.start_pixel, FEATURE_HEIGHT).fill
                          track_drawing.move_to(range_with_arrow.stop_pixel-FEATURE_ARROW_LENGTH, top_pixel_of_feature)
                          track_drawing.rel_line_to(FEATURE_ARROW_LENGTH, FEATURE_HEIGHT/2)
                          track_drawing.rel_line_to(-FEATURE_ARROW_LENGTH, FEATURE_HEIGHT/2)
                        end
                        gap_starts.push(range_with_arrow.stop_pixel)
                        gap_stops.push(range_with_arrow.start_pixel)
  
                        #   And then add the others
                        pixel_ranges.each do |range|
                          track_drawing.rectangle(range.start_pixel, top_pixel_of_feature, range.stop_pixel - range.start_pixel, FEATURE_HEIGHT).fill
                          gap_starts.push(range.stop_pixel)
                          gap_stops.push(range.start_pixel)
                        end
  
                        # And then draw the connections in the gaps
                        # Start with removing the very first start and the very last stop.
                        gap_starts.sort!.pop
                        gap_stops.sort!.shift
  
                        gap_starts.length.times do |gap_number|
                          from = gap_starts[gap_number].to_f
                          to = gap_stops[gap_number].to_f
                          middle = from + ((to - from)/2)
                          track_drawing.move_to(from, top_pixel_of_feature+2)
                          track_drawing.line_to(middle, top_pixel_of_feature+7)
                          track_drawing.line_to(to, top_pixel_of_feature+2)
                          track_drawing.stroke
                        end
  
                      else #treat as 'generic'
                        left_pixel_of_feature, right_pixel_of_feature = feature.pixel_range_collection[0].start_pixel, feature.pixel_range_collection[0].stop_pixel
                        track_drawing.rectangle(left_pixel_of_feature, top_pixel_of_feature, (right_pixel_of_feature - left_pixel_of_feature), FEATURE_HEIGHT).fill
                    end
  
                    # And add the region to the image map
                    if panel.clickable
                      # Comment: we have to add the vertical_offset and TRACK_HEADER_HEIGHT!
                      panel.image_map.elements.push(ImageMap::ImageMapElement.new(left_pixel_of_feature,
                                                                                  top_pixel_of_feature + vertical_offset + TRACK_HEADER_HEIGHT,
                                                                                  right_pixel_of_feature,
                                                                                  bottom_pixel_of_feature + vertical_offset + TRACK_HEADER_HEIGHT,
                                                                                  feature.link
                                                                                  ))
                    end
  
  
                    feature_drawn = true
                  end
                end
              end
            end

          end

          @number_of_times_bumped = ( grid.keys.length == 0 ) ? 1 : grid.keys.max + 1

          return panel_drawing
        end

      end #Track
    end #Panel
  end #Graphics
end #Bio
