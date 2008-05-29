# 
# = bio-graphics.rb - Loading all Bio::Graphics modules
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@gmail.com>
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

class Integer
  def commify
    self.to_s =~ /([^\.]*)(\..*)?/
    int, dec = $1.reverse, $2 ? $2 : ""
    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
    end
    int.reverse + dec
  end
end

class String
  def snake_case
   return self.to_s.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end
    
  def camel_case
    return self.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end
  
  def to_class
    parts = self.split(/::/)
    klass = Kernel
    parts.each do |part|
      klass = klass.const_get(part)
    end
    return klass
  end
end

require File.dirname(__FILE__) + '/feature.rb'
require File.dirname(__FILE__) + '/bio/graphics/panel.rb'
require File.dirname(__FILE__) + '/bio/graphics/image_map.rb'
require File.dirname(__FILE__) + '/bio/graphics/track.rb'
require File.dirname(__FILE__) + '/bio/graphics/feature.rb'
require File.dirname(__FILE__) + '/bio/graphics/subfeature.rb'
require File.dirname(__FILE__) + '/bio/graphics/ruler.rb'

# Load all the glyphs
glyph_dir = File.dirname(__FILE__) + '/bio/graphics/glyphs/'
require glyph_dir + '/common.rb'
full_pattern = File.join(glyph_dir, '*.rb')
Dir.glob(full_pattern).each do |file|
  require file
end