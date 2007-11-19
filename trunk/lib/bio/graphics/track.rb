# 
# = bio/graphics/track - track class
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

# The Bio::Graphics::Track class describes the container for features of
# the same type. See Bio::Graphics documentation for explanation of
# interplay between different classes.
class Bio::Graphics::Panel::Track
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
  # * _label_ :: Boolean: should the label for each feature be drawn or not
  #   Default = true
  # * _glyph_ :: Glyph to use for drawing the features. Options are:
  #   :generic, :directed_generic, :spliced, :directed_spliced, :dot
  #   :triangle, :line and :line_with_handles. Default = :generic
  # * _colour_ :: Colour to be used to draw the features within the track.
  #   Default = [0,0,1] (i.e. blue)
  # *Returns*:: Bio::Graphics::Track object
  def initialize(panel, name, label = true, glyph = :generic, colour = [0,0,1])
    @panel = panel
    @name = name
    @show_label = label
    @glyph = glyph
    @colour = colour
    @features = Array.new
    @number_of_feature_rows = 0
    @vertical_offset = 0
    @grid = Hash.new
  end
  attr_accessor :panel, :name, :show_label, :colour, :glyph, :features, :number_of_feature_rows, :height, :vertical_offset, :grid

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
  # * _feature_ _object_ (required) :: A Bio::Feature object
  # * _label_ :: Label for the feature. Default = 'anonymous'
  # * _link_ :: URL to link to for this glyph. Default = nil
  # * _glyph_ :: Glyph for the feature. Default = glyph of the track
  # * _colour_ :: Colour for the feature. Default = colour of the track
  # *Returns*:: Bio::Graphics::Track::Feature object that was created or nil
  def add_feature(feature_object, label = 'anonymous', link = nil, glyph = @glyph, colour = @colour)
    if link == ''
      link = nil
    end

    # Calculate the ultimate start and stop of the feature: the start
    # of the first subfeature (e.g. exon) and the stop of the last one.
    # The only reason we want to know these positions, is because we want
    # to determine if the feature falls within the view of the image or
    # not (see below).
    start = feature_object.locations.collect{|l| l.from}.min.to_i
    stop = feature_object.locations.collect{|l| l.to}.max.to_i

    # If the feature wouldn't show because it's not in the region we're
    # looking at, don't bother storing the stuff. I think this makes huge
    # speed and memory differences if you've got a chromosome with
    # thousands of features.
    if stop <= self.panel.display_start or start >= self.panel.display_stop
      return nil
    else #elsif start >= panel.display_start and stop <= panel.display_stop
      @features.push(Bio::Graphics::Panel::Track::Feature.new(self, feature_object, label, link, glyph, colour))
      return @features[-1]
    end

    return self
  end


  # Adds the track to a cairo drawing. This method should not be used
  # directly by the user, but is called by Bio::Graphics::Panel.draw
  # ---
  # *Arguments*:
  # * _panel__drawing_ (required) :: the panel cairo object
  # *Returns*:: FIXME: I don't know
  def draw(panel_drawing)
    track_drawing = Cairo::Context.new(panel_drawing)

    # Draw thin line above title
    track_drawing.set_source_rgb(0.75,0.75,0.75)
    track_drawing.move_to(0, self.vertical_offset)
    track_drawing.line_to(self.panel.width, self.vertical_offset)
    track_drawing.stroke

    # Draw track title
    track_drawing.set_source_rgb(0,0,0)
    track_drawing.select_font_face(*(Bio::Graphics::FONT))
    track_drawing.set_font_size(Bio::Graphics::TRACK_HEADER_HEIGHT)
    track_drawing.move_to(0,Bio::Graphics::TRACK_HEADER_HEIGHT + self.vertical_offset + 10)
    track_drawing.show_text(self.name)

    # Draw the features
    track_drawing.save do
      track_drawing.translate(0, self.vertical_offset + Bio::Graphics::TRACK_HEADER_HEIGHT)
#            track_drawing.set_source_rgb(@colour)

      @features.sort_by{|f| f.start}.each do |feature|
        # Don't even bother if the feature is not in the view
        if feature.stop <= self.panel.display_start or feature.start >= self.panel.display_stop
          next
        else
          feature.draw(track_drawing)
        end
      end

    end

    @number_of_feature_rows = ( @grid.keys.length == 0 ) ? 1 : @grid.keys.max + 1

    return panel_drawing
  end

end #Track

