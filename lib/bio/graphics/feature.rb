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
