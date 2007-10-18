# 
# = bio/graphics/ruler - ruler class
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
module Bio
  module Graphics
    class Panel
      # The Bio::Graphics::Ruler class describes the ruler to be drawn on the
      # graph. This is created automatically when creating the picture by using
      # Bio::Graphics::Panel.to_svg. See BioExt::Graphics documentation for
      # explanation of interplay between different classes.
      #--
      # TODO: the ruler might be implemented as a special case of a track, so
      # it would inherit from it (class Ruler < Bio::Graphics::Panel::Track).
      # But I haven't really thought this through yet.
      #++
      class Ruler
        # Creates a new Bio::Graphics::Panel::Ruler object.
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
        end
        attr_accessor :panel, :name, :colour, :height, :minor_tick_distance, :major_tick_distance

        def calculate_tick_distance
          min_tick_distance_requirement_met = false
          self.minor_tick_distance = 1 # in basepairs.
          while ! min_tick_distance_requirement_met
            if self.minor_tick_distance/panel.rescale_factor >= RULER_MIN_DISTANCE_TICKS_PIXEL
              min_tick_distance_requirement_met = true
            else
              self.minor_tick_distance = self.minor_tick_distance*5
            end
          end

          self.major_tick_distance = self.minor_tick_distance * 10
        end

        def draw(panel_drawing, vertical_offset)
          ruler_drawing = Cairo::Context.new(panel_drawing)

          self.calculate_tick_distance

          # Draw line
          ruler_drawing.move_to(0,10)
          ruler_drawing.line_to(panel.width, 10)
          ruler_drawing.stroke

          # Draw ticks
          #  * Find position of first tick.
          #    Most of the time, we don't want the first tick on the very first
          #    basepair of the view. Suppose that would be position 333 in the
          #    sequence. Then the numbers under the major tickmarks would be:
          #    343, 353, 363, 373 and so on. Instead, we want 350, 360, 370, 380.
          #    So we want to find the position of the first tick.
          first_tick_position = panel.display_start
          while first_tick_position.modulo(minor_tick_distance) != 0
            first_tick_position += 1
          end
          
          #  * And start drawing the rest.
          first_tick_position.step(panel.display_stop, minor_tick_distance) do |tick|
            tick_pixel_position = (tick - panel.display_start) / panel.rescale_factor
            ruler_drawing.move_to(tick_pixel_position.floor, 5)
            if tick.modulo(major_tick_distance) == 0
              ruler_drawing.rel_line_to(0, 15)
              
              # Draw tick number
              ruler_drawing.select_font_face(*(FONT))
              ruler_drawing.set_font_size(RULER_TEXT_HEIGHT)
              ruler_drawing.move_to(tick_pixel_position.floor, 20 + RULER_TEXT_HEIGHT)
              ruler_drawing.show_text(tick.to_i.to_s)
            else
              ruler_drawing.rel_line_to(0, 5)
              
            end
            ruler_drawing.stroke
          end
          

          @height = 25 + RULER_TEXT_HEIGHT
        end
      end #Ruler
    end #Panel
  end #Graphics
end #Bio
