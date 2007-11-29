# 
# = bio/graphics/ruler - ruler class
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
#               Charles Comstock <dgtized@gmail.com>
# License::     The Ruby License
#

# The Bio::Graphics::Ruler class describes the ruler to be drawn on the
# graph. This is created automatically when creating the picture by using
# Bio::Graphics::Panel.to_svg. See BioExt::Graphics documentation for
# explanation of interplay between different classes.
#--
# TODO: the ruler might be implemented as a special case of a track, so
# it would inherit from it (class Ruler < Bio::Graphics::Track).
# But I haven't really thought this through yet.
#++
class Bio::Graphics::Ruler        
  # Creates a new Bio::Graphics::Ruler object.
  # ---
  # *Arguments*:
  # * _panel_ (required) :: Bio::Graphics::Panel object that this ruler
  #   belongs to
  # * _colour_ :: colour of the ruler. Default = 'black'
  # *Returns*:: Bio::Graphics::Ruler object
  def initialize(panel, colour = [0,0,0])
    @panel = panel
    @name = 'ruler'
    @colour = colour
    
    # Number of pixels between each tick, used to calculate tick spacing
    @min_pixels_per_tick = 5
    # The base height of minor ticks in pixels
    @tick_height = 5
    # The height of the text in pixels
    @tick_text_height = 10

    @minor_tick_distance = @min_pixels_per_tick ** self.scaling_factor
    @major_tick_distance = @minor_tick_distance * 10       
  end
  attr_accessor(:panel, :name, :colour, :height,
                :minor_tick_distance, :major_tick_distance,
                :min_pixels_per_tick, :tick_height, :tick_text_height)

  def scaling_factor(min_pixels_per_tick = @min_pixels_per_tick,
                          rescale_factor = @panel.rescale_factor)
    (Math.log(min_pixels_per_tick * rescale_factor) /
     Math.log(min_pixels_per_tick)).ceil 
  end

  def first_tick_position(start = @panel.display_start,
                          minor_tick = @minor_tick_distance)
    #  * Find position of first tick.
    #    Most of the time, we don't want the first tick on the very first
    #    basepair of the view. Suppose that would be position 333 in the
    #    sequence. Then the numbers under the major tickmarks would be:
    #    343, 353, 363, 373 and so on. Instead, we want 350, 360, 370, 380.
    #    So we want to find the position of the first tick.
    modulo_from_tick = (start % minor_tick)
    start + (modulo_from_tick > 0 ? (minor_tick - modulo_from_tick + 1) : 0)
  end
  
  def draw(panel_drawing)
    ruler_drawing = Cairo::Context.new(panel_drawing)

    # Draw line
    ruler_drawing.move_to(0,10)
    ruler_drawing.line_to(panel.width, 10)
    ruler_drawing.stroke

    # Draw ticks
    #  * And start drawing the rest.
    first_tick_position.step(@panel.display_stop, @minor_tick_distance) do |tick|
      tick_pixel_position = (tick - panel.display_start) / @panel.rescale_factor
      ruler_drawing.move_to(tick_pixel_position.floor, @min_pixels_per_tick)
      if tick.modulo(@major_tick_distance) == 0
        ruler_drawing.rel_line_to(0, 3*@tick_height)
        
        # Draw tick number
        ruler_drawing.select_font_face(*Bio::Graphics::FONT)
        ruler_drawing.set_font_size(@tick_text_height)
        ruler_drawing.move_to(tick_pixel_position.floor, 4*@tick_height + @tick_text_height)
        ruler_drawing.show_text(tick.to_i.to_s)
      else
        ruler_drawing.rel_line_to(0, @tick_height)
        
      end
      ruler_drawing.stroke
    end

    @height = 5*@tick_height + @tick_text_height          
  end
end

