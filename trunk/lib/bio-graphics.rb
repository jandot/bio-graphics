# 
# = bio-graphics.rb - Loading all Bio::Graphics modules
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
# 

#--
# We're referencing the module and class names here so that we don't have to 
# do
# module Bio
#   module Graphics
#     class Panel
#       class Track
#         class Feature
#           class SubFeature
#             a_lot_of_spaces_before_we_can_do_anything
#           end
#         end
#       end
#     end
#   end
# end
Bio = Module.new
Bio::Graphics = Module.new
Bio::Graphics::Panel = Class.new
Bio::Graphics::Panel::Track = Class.new
Bio::Graphics::Panel::Track::Feature = Class.new
Bio::Graphics::Panel::Track::Feature::SubFeature = Class.new

begin
  require 'bio'
  require 'cairo'
  require 'pango'
  require 'stringio'
end

#require File.dirname(__FILE__) + '/feature.rb'
require File.dirname(__FILE__) + '/bio/graphics/image_map.rb'
require File.dirname(__FILE__) + '/bio/graphics/panel.rb'
require File.dirname(__FILE__) + '/bio/graphics/track.rb'
require File.dirname(__FILE__) + '/bio/graphics/feature.rb'
require File.dirname(__FILE__) + '/bio/graphics/subfeature.rb'
require File.dirname(__FILE__) + '/bio/graphics/ruler.rb'

