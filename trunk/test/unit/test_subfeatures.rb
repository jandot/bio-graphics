require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/bio-graphics'

class TestSubFeature < Test::Unit::TestCase
  def setup
    @utr5 = Bio::Feature.new('utr', '100..150')
    @cds = Bio::Feature.new('cds', 'join(150..225, 250..275, 310..330)')
    @utr3 = Bio::Feature.new('utr', '330..375')
    @transcript = Bio::Feature.new('transcript', 'join(100..150, 150..225, 250..275, 310..330, 330..375)', [], nil, [@utr5,@cds,@utr3])
  end
  
  def test_existence_subfeatures
    assert_equal(3, @transcript.subfeatures.length)
  end
  
  
end
