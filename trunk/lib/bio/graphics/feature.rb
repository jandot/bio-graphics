require 'yaml'
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
          def draw(track_drawing)
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
            if self.track.glyph == :directed_generic and replace_directed_with_undirected
              local_feature_glyph = :generic
            elsif self.track.glyph == :directed_spliced and replace_directed_with_undirected
              local_feature_glyph = :spliced
            else
              local_feature_glyph = self.track.glyph
            end

            # And draw the thing.
            row = self.find_row
            top_pixel_of_feature = FEATURE_V_DISTANCE + (FEATURE_HEIGHT+FEATURE_V_DISTANCE)*row
            bottom_pixel_of_feature = top_pixel_of_feature + FEATURE_HEIGHT

            case local_feature_glyph
              # triangles are typical for features which have a 1 bp position (start == stop)
              when :triangle
                raise "Start and stop are not the same (necessary if you want triangle glyphs)" if self.start != self.stop
 
                # Need to get this for the imagemap
                left_pixel_of_feature = self.pixel_range_collection[0].start_pixel - FEATURE_ARROW_LENGTH
                right_pixel_of_feature = self.pixel_range_collection[0].stop_pixel + FEATURE_ARROW_LENGTH
                arrow(track_drawing,:north,left_pixel_of_feature + FEATURE_ARROW_LENGTH, top_pixel_of_feature, FEATURE_ARROW_LENGTH)
                track_drawing.close_path.stroke
              when :line
                left_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                right_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
                track_drawing.move_to(left_pixel_of_feature,top_pixel_of_feature+FEATURE_ARROW_LENGTH)               
                track_drawing.line_to(right_pixel_of_feature,top_pixel_of_feature+FEATURE_ARROW_LENGTH)
                track_drawing.stroke

                track_drawing.set_source_rgb([0,0,0])
                arrow(track_drawing,:right,left_pixel_of_feature,top_pixel_of_feature,FEATURE_ARROW_LENGTH)
                track_drawing.close_path.stroke              
                arrow(track_drawing,:left,right_pixel_of_feature,top_pixel_of_feature,FEATURE_ARROW_LENGTH)
                track_drawing.close_path.stroke

                track_drawing.set_source_rgb(self.track.colour)
            when :directed_generic
                # Need to get this for the imagemap
                left_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                right_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
                if self.strand == -1 # Reverse strand
                  track_drawing.rectangle(left_pixel_of_feature+FEATURE_ARROW_LENGTH, top_pixel_of_feature, right_pixel_of_feature - left_pixel_of_feature - FEATURE_ARROW_LENGTH, FEATURE_HEIGHT).fill
                  arrow(track_drawing,:left,left_pixel_of_feature+FEATURE_ARROW_LENGTH,top_pixel_of_feature,FEATURE_ARROW_LENGTH)
                  track_drawing.close_path.fill
                else #default is forward strand
                  track_drawing.rectangle(left_pixel_of_feature, top_pixel_of_feature, right_pixel_of_feature - left_pixel_of_feature - FEATURE_ARROW_LENGTH, FEATURE_HEIGHT).fill
                  arrow(track_drawing,:right,right_pixel_of_feature-FEATURE_ARROW_LENGTH,top_pixel_of_feature,FEATURE_ARROW_LENGTH)
                  track_drawing.close_path.fill
                end
              when :spliced
                # Need to get this for the imagemap
                left_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                right_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel

                pixel_ranges = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}
                draw_spliced(track_drawing, pixel_ranges, top_pixel_of_feature, [], [])
              when :directed_spliced
                gap_starts = Array.new
                gap_stops = Array.new

                # Need to get this for the imagemap
                left_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
                right_pixel_of_feature = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel

                #   Start with the one with the arrow
                pixel_ranges = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}
                range_with_arrow = nil
                if self.strand == -1 # reverse strand => box with arrow is first one
                  range_with_arrow = pixel_ranges.shift
                  track_drawing.rectangle((range_with_arrow.start_pixel)+FEATURE_ARROW_LENGTH, top_pixel_of_feature, range_with_arrow.stop_pixel - range_with_arrow.start_pixel - FEATURE_ARROW_LENGTH, FEATURE_HEIGHT).fill
                  arrow(track_drawing,:left,range_with_arrow.start_pixel+FEATURE_ARROW_LENGTH, top_pixel_of_feature,FEATURE_ARROW_LENGTH)
                  track_drawing.close_path.fill
                else # forward strand => box with arrow is last one
                  range_with_arrow = pixel_ranges.pop
                  track_drawing.rectangle(range_with_arrow.start_pixel, top_pixel_of_feature, range_with_arrow.stop_pixel - range_with_arrow.start_pixel - FEATURE_ARROW_LENGTH, FEATURE_HEIGHT).fill
                  arrow(track_drawing,:right,range_with_arrow.stop_pixel-FEATURE_ARROW_LENGTH, top_pixel_of_feature,FEATURE_ARROW_LENGTH)
                  track_drawing.close_path.fill
                end
                gap_starts.push(range_with_arrow.stop_pixel)
                gap_stops.push(range_with_arrow.start_pixel)

                #   And then add the others
                draw_spliced(track_drawing, pixel_ranges, top_pixel_of_feature, gap_starts, gap_stops)
              else #treat as 'generic'
                left_pixel_of_feature, right_pixel_of_feature = self.pixel_range_collection[0].start_pixel, self.pixel_range_collection[0].stop_pixel
                track_drawing.rectangle(left_pixel_of_feature, top_pixel_of_feature, (right_pixel_of_feature - left_pixel_of_feature), FEATURE_HEIGHT).fill
            end

            # Add the label for the feature
            if self.track.show_label
              pango_layout = track_drawing.create_pango_layout
              pango_layout.text = self.name
              fdesc = Pango::FontDescription.new('Sans Serif')
              fdesc.set_size(8 * Pango::SCALE)
              pango_layout.font_description = fdesc
  
              text_range = self.start.floor..(self.start.floor + pango_layout.pixel_size[0]*self.track.panel.rescale_factor)
              if self.track.grid[row+1].nil?
                self.track.grid[row+1] = Array.new
              end
              self.track.grid[row].push(text_range)
              self.track.grid[row+1].push(text_range)
              track_drawing.move_to(left_pixel_of_feature, top_pixel_of_feature + TRACK_HEADER_HEIGHT)
              track_drawing.set_source_rgb(0,0,0)
              track_drawing.show_pango_layout(pango_layout)
              track_drawing.set_source_rgb(self.track.colour)
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
            feature_range = (self.start.floor..self.stop.ceil)
            row = 1
            row_available = true
            until row_found
              if ! self.track.grid[row].nil?
                self.track.grid[row].each do |covered|
                  if feature_range.include?(covered.first) or covered.include?(feature_range.first)
                    row_available = false
                  end
                end
              end
  
              if ! row_available
                row += 1
                row_available = true
              else # We've found the place where to draw the feature.
                if self.track.grid[row].nil?
                  self.track.grid[row] = Array.new
                end
                self.track.grid[row].push(feature_range)
                row_found = true
              end
            end
            return row
          end

          class PixelRange
            def initialize(start_pixel, stop_pixel)
              @start_pixel, @stop_pixel = start_pixel, stop_pixel
            end
            attr_accessor :start_pixel, :stop_pixel
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
              track_drawing.rectangle(range.start_pixel, top_pixel_of_feature, range.stop_pixel - range.start_pixel, FEATURE_HEIGHT).fill
              gap_starts.push(range.stop_pixel)
              gap_stops.push(range.start_pixel)
            end

            # And then draw the connections in the gaps
            # Start with removing the very first start and the very last stop.
            gap_starts.sort!.pop
            gap_stops.sort!.shift

            gap_starts.length.times do |gap_number|
              connector(track_drawing,gap_starts[gap_number].to_f,gap_stops[gap_number].to_f,top_pixel_of_feature)
            end

            if self.hidden_subfeatures_at_stop
              from = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[-1].stop_pixel
              to = self.track.panel.width
              track_drawing.move_to(from, top_pixel_of_feature+FEATURE_ARROW_LENGTH)
              track_drawing.line_to(to, top_pixel_of_feature+FEATURE_ARROW_LENGTH)
              track_drawing.stroke
            end

            if self.hidden_subfeatures_at_start
              from = 1
              to = self.pixel_range_collection.sort_by{|pr| pr.start_pixel}[0].start_pixel
              track_drawing.move_to(from, top_pixel_of_feature+FEATURE_ARROW_LENGTH)
              track_drawing.line_to(to, top_pixel_of_feature+FEATURE_ARROW_LENGTH)
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
            track.set_source_rgb(self.track.colour)
          end                    
        end #Feature
      end #Track
    end #Panel
  end #Graphics
end #Bio
