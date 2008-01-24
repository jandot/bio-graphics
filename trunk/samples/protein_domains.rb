# Data from http://pfam.sanger.ac.uk/protein?id=Q8C6V9_MOUSE
require '../lib/bio-graphics'
my_panel = Bio::Graphics::Panel.new(700, :width => 600)

track = my_panel.add_track('Q8C6V9_MOUSE')
track.glyph = :generic

# First make the Bio::Feature objects and then create a Bio::Graphics feature
cimr_1 = Bio::Feature.new('CIMR', '3..142')
fn2 = Bio::Feature.new('fn2', '151..190')
cimr_2 = Bio::Feature.new('CIMR', '194..331')
cimr_3 = Bio::Feature.new('CIMR', '485..527')

track.add_feature(cimr_1, :label => 'CIMR', :colour => [0,1,0])
track.add_feature(fn2, :label => 'fn2', :colour => [1,0,0])
track.add_feature(cimr_2, :label => 'CIMR', :colour => [0,1,0])
track.add_feature(cimr_3, :label => 'CIMR', :colour => [0,1,0])

my_panel.draw('protein_domains.png')
