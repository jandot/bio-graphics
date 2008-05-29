require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/bio-graphics'

class TestExtensions < Test::Unit::TestCase
  def test_range
    r = (1..5)
    assert_equal(1, r.begin)
    assert_equal(5, r.end)
    assert_equal(1, r.lend)
    assert_equal(5, r.rend)
  end
  
  def test_string
    snake = 'this_is_a_string'
    assert_equal('ThisIsAString', snake.camel_case)
    
    camel = 'ThisIsAnotherString'
    assert_equal('this_is_another_string', camel.snake_case)
    
    class_name = 'Bio::Graphics::Glyph::Generic'
    assert(class_name.to_class == Bio::Graphics::Glyph::Generic)
  end
end
