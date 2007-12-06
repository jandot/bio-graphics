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
require File.dirname(__FILE__) + '/bio/graphics/glyphs/common.rb'
Dir.new(File.dirname(__FILE__) + '/bio/graphics/glyphs').reject{|f| f == 'common.rb'}.select{|f| f =~ /\.rb$/}.each do |glyph_file_name|
  require File.dirname(__FILE__) + '/bio/graphics/glyphs/' + glyph_file_name
end
