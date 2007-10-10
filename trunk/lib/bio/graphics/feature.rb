# 
# = bio/graphics/feature.rb - feature class
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
# 
module Bio
  module Graphics
    class Panel
      class Track
        # The Bio::Graphics::Track::Feature class describes features to be
        # placed on the graph. See Bio::Graphics documentation for explanation
        # of interplay between different classes.
        #
        # The position of the Feature is a Bio::Locations object to make it possible
        # to transparently work with simple and spliced features.
        class Feature
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
          # * _panel_ (required) :: Bio::Graphics::Panel::Track object that this
          #   feature belongs to
          # * _name_ (required) :: Name of the feature
          # * _location_ :: Bio::Locations object. Default = whole panel, forward strand
          # * _link_ :: URL for clickable images
          # *Returns*:: Bio::Graphics::Track::Feature object
          def initialize(track, name, location = Bio::Locations.new('1..' + track.panel.length.to_s), link = nil)
            @track = track
            @name = name
            @location = location
            @start = location.collect{|l| l.from}.min.to_i
            @stop = location.collect{|l| l.to}.max.to_i
            @strand = location[0].strand.to_i
            @link = link
            @pixel_range_collection = Array.new
            @chopped_at_start = false
            @chopped_at_stop = false
            @hidden_subfeatures_at_start = false
            @hidden_subfeatures_at_stop = false

            # Get all pixel ranges for the subfeatures
            location.each do |l|
              #   xxxxxx  [          ]
              if l.to < track.panel.display_start
                @hidden_subfeatures_at_start = true
                next
              #           [          ]   xxxxx
              elsif l.from > track.panel.display_stop
                @hidden_subfeatures_at_stop = true
                next
              #      xxxx[xxx       ]
              elsif l.from < track.panel.display_start and l.to > track.panel.display_start
                start_pixel = 1
                stop_pixel = ( l.to - track.panel.display_start ).to_f / track.panel.rescale_factor
                @chopped_at_start = true
              #          [      xxxx]xxxx
              elsif l.from < track.panel.display_stop and l.to > track.panel.display_stop
                start_pixel = ( l.from - track.panel.display_start ).to_f / track.panel.rescale_factor
                stop_pixel = track.panel.width
                @chopped_at_stop = true
              #      xxxx[xxxxxxxxxx]xxxx
              elsif l.from < track.panel.display_start and l.to > track.panel.display_stop
                start_pixel = 1
                stop_pixel = track.panel.width
                @chopped_at_start = true
                @chopped_at_stop = true
              #          [   xxxxx  ]
              else
                start_pixel = ( l.from - track.panel.display_start ).to_f / track.panel.rescale_factor
                stop_pixel = ( l.to - track.panel.display_start ).to_f / track.panel.rescale_factor
              end
              
              @pixel_range_collection.push(PixelRange.new(start_pixel, stop_pixel))
              
            end
          end
          
          # The track that this feature belongs to
          attr_accessor :track
          
          # The name of the feature
          attr_accessor :name
          
          # The location of the feature (which is a Bio::Locations object)
          attr_accessor :location
          
          # The start position of the feature (in bp)
          attr_accessor :start
          
          # The stop position of the feature (in bp)
          attr_accessor :stop
          
          # The strand of the feature
          attr_accessor :strand
          
          # The URL to be followed when the glyph for this feature is clicked
          attr_accessor :link
          
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

          # Adds the feature to the track cairo context. This method should not 
          # be used directly by the user, but is called by
          # Bio::Graphics::Panel::Track.draw
          # ---
          # *Arguments*:
          # * _trackdrawing_ (required) :: the track cairo object
          # * _row_ (required) :: row within the track that this feature has 
          #                       been bumped to
          # *Returns*:: FIXME: I don't know
          def draw(track_drawing, row)
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
            if (self.stop - self.start).to_f/self.track.panel.rescale_factor.to_f < 2
              replace_directed_with_undirected = true
            end
            # (b) Extending beyond borders picture
            if ( self.chopped_at_stop and self.strand = 1 ) or ( self.chopped_at_start and self.strand = -1 )
              replace_directed_with_undirected = true
            end

            local_feature_glyph = nil
            if self.track.glyph == 'directed_generic' and replace_directed_with_undirected
              local_feature_glyph = 'generic'
            elsif self.track.glyph == 'directed_spliced' and replace_directed_with_undirected
              local_feature_glyph = 'spliced'
            else
              local_feature_glyph = self.track.glyph
            end

            # And draw the thing.
            top_pixel_of_feature = FEATURE_V_DISTANCE + (FEATURE_HEIGHT+FEATURE_V_DISTANCE)*row
            bottom_pixel_of_feature = top_pixel_of_feature + FEATURE_HEIGHT

            case local_feature_glyph
              # triangles are typical for features which have a 1 bp position (start == stop)
              when 'triangle'
                raise "Start and stop are not the same (necessary if you want triangle glyphs)" if self.start != self.stop
 
                # Need to get this for the imagemap
                left_pixel_of_feature = self.pixel_range_collection[0].start_pixel - 3
                right_pixel_of_feature = self.pixel_range_collection[0].stop_pixel + 3
                track_drawing.move_to(left_pixel_of_feature + 3, top_pixel_of_feature)
                track_drawing.rel_line_to(-3, FEATURE_HEIGHT)
                track_drawing.rel_line_to(6, 0)
                track_drawing.close_path.fill

              when 'directed_generic'
                # Need to get this for the imagemap
                left_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                right_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
                if self.strand == -1 # Reverse strand
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
                left_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                right_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel

                # First draw the parts
                self.pixel_range_collection.sort_by{|pr| pr.start_pixel}.each do |pr|
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

                if self.hidden_subfeatures_at_stop
                  from = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
                  to = self.track.panel.width
                  track_drawing.move_to(from, top_pixel_of_feature+5)
                  track_drawing.line_to(to, top_pixel_of_feature+5)
                  track_drawing.stroke
                end

                if self.hidden_subfeatures_at_start
                  from = 1
                  to = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                  track_drawing.move_to(from, top_pixel_of_feature+5)
                  track_drawing.line_to(to, top_pixel_of_feature+5)
                  track_drawing.stroke
                end

              when 'directed_spliced'
                gap_starts = Array.new
                gap_stops = Array.new
                # First draw the parts
                locations = self.location.sort_by{|l| l.from}

                # Need to get this for the imagemap
                left_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                right_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel

                #   Start with the one with the arrow
                pixel_ranges = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}
                range_with_arrow = nil
                if self.strand == -1 # reverse strand => box with arrow is first one
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

                if self.hidden_subfeatures_at_stop
                  from = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
                  to = self.track.panel.width
                  track_drawing.move_to(from, top_pixel_of_feature+5)
                  track_drawing.line_to(to, top_pixel_of_feature+5)
                  track_drawing.stroke
                end

                if self.hidden_subfeatures_at_start
                  from = 1
                  to = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                  track_drawing.move_to(from, top_pixel_of_feature+5)
                  track_drawing.line_to(to, top_pixel_of_feature+5)
                  track_drawing.stroke
                end

              else #treat as 'generic'
                left_pixel_of_feature, right_pixel_of_feature = self.pixel_range_collection[0].start_pixel, self.pixel_range_collection[0].stop_pixel
                track_drawing.rectangle(left_pixel_of_feature, top_pixel_of_feature, (right_pixel_of_feature - left_pixel_of_feature), FEATURE_HEIGHT).fill
            end

            # And add the region to the image map
            if self.track.panel.clickable
              # Comment: we have to add the vertical_offset and TRACK_HEADER_HEIGHT!
              self.track.panel.image_map.elements.push(ImageMap::ImageMapElement.new(left_pixel_of_feature,
                                                                                     top_pixel_of_feature + self.track.vertical_offset + TRACK_HEADER_HEIGHT,
                                                                                     right_pixel_of_feature,
                                                                                     bottom_pixel_of_feature + self.track.vertical_offset + TRACK_HEADER_HEIGHT,
                                                                                     self.link
                                                                                    ))
            end
          end
          
          class PixelRange
            def initialize(start_pixel, stop_pixel)
              @start_pixel, @stop_pixel = start_pixel, stop_pixel
            end
            attr_accessor :start_pixel, :stop_pixel
          end
        end #Feature
      end #Track
    end #Panel
  end #Graphics
end #Bio
