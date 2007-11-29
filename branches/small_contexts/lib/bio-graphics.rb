# 
# = bio-graphics.rb - Loading all Bio::Graphics modules
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
#               Charles Comstock <dgtized@gmail.com>
# License::     The Ruby License
# 

require 'bio'
require 'cairo'
require 'pango'
require 'stringio'

class Range
  alias :lend :begin
  alias :rend :end
end

require File.dirname(__FILE__) + '/feature.rb'
require File.dirname(__FILE__) + '/bio/graphics/panel.rb'
require File.dirname(__FILE__) + '/bio/graphics/image_map.rb'
require File.dirname(__FILE__) + '/bio/graphics/track.rb'
require File.dirname(__FILE__) + '/bio/graphics/feature.rb'
require File.dirname(__FILE__) + '/bio/graphics/subfeature.rb'
require File.dirname(__FILE__) + '/bio/graphics/ruler.rb'

