#
# = bio/graphics/image_map.rb - create the image map for clickable images
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
#               Charles Comstock <dgtized@gmail.com>
# License::     Ruby's
class Bio::Graphics::ImageMap
  def initialize
    @elements = Array.new
  end
  attr_accessor :elements

  def add_element(left,top,right,bottom,url = nil)
    @elements.push(Element.new(left,top,right,bottom,url))
  end
  
  def to_s
    output = Array.new
    output.push('<map name="image_map" border="1">')
    @elements.each do |e|
      area = e.to_s
      if area != ''
        output.push(e.to_s)
      end
    end
    output.push('</map>')
    return output.join("\n")
  end


  # Switch horizontal to vertical orientation
  def flip_orientation(width)
    @elements.each do |element|
      left, top, right, bottom = element.left, element.top, element.right, element.bottom
      element.left = top
      element.top = width - right
      element.right = bottom
      element.bottom = width - left
    end
  end
  
  class Element
    def initialize(left, top, right, bottom, url = nil)
      @left, @top, @right, @bottom = left, top, right, bottom
      @url = ( url.nil? ) ? '' : url
    end
    attr_accessor :left, :top, :right, :bottom, :url

    def to_s
      if @url == ''
        return ''
      else
        return '<area shape="rect" coords="' + @left.to_s + ' ' + @top.to_s + ' ' + @right.to_s + ' ' + @bottom.to_s + '" href="' + @url + '"/>'
      end
    end
  end
end
