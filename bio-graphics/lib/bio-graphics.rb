# 
# = bio-graphics.rb - Loading all Bio::Graphics modules
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
# 
begin
  require 'bio'
  require 'cairo'
  rescue nil
end

require File.dirname(__FILE__) + '/bio/graphics/image_map.rb'
require File.dirname(__FILE__) + '/bio/graphics/panel.rb'
require File.dirname(__FILE__) + '/bio/graphics/track.rb'
require File.dirname(__FILE__) + '/bio/graphics/feature.rb'
require File.dirname(__FILE__) + '/bio/graphics/ruler.rb'
