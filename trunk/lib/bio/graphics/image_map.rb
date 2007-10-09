#
# = bio/graphics/image_map.rb - create the image map for clickable images
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     Ruby's
class ImageMap
  def initialize
    @elements = Array.new
  end
  attr_accessor :elements

  def to_s
    output = Array.new
    output.push('<map name="image_map" border="1">')
    @elements.each do |e|
      output.push(e.to_s)
    end
    output.push('</map>')
    return output.join("\n")
  end


  class ImageMapElement
    def initialize(left, top, right, bottom, url = nil)
      @left, @top, @right, @bottom = left, top, right, bottom
      @url = ( url.nil? ) ? '' : url
    end
    attr_accessor :left, :top, :right, :bottom, :url

    def to_s
      unless @url == ''
        return '<area shape="rect" coords="' + @left.to_s + ' ' + @top.to_s + ' ' + @right.to_s + ' ' + @bottom.to_s + '" href="' + @url + '"/>'
      end
    end
  end
end
