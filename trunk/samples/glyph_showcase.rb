require '../lib/bio-graphics'

my_panel = Bio::Graphics::Panel.new(500, :width => 1000, :format => :svg)

generic_track = my_panel.add_track('generic', :label => false)
box_track = my_panel.add_track('box', :label => false, :glyph => :box)
line_track = my_panel.add_track('line', :label => false, :glyph => :line, :colour => [0,0,1])
line_with_handles_track = my_panel.add_track('line_with_handles', :label => false, :glyph => :line_with_handles, :colour => [1,0,0])
directed_track = my_panel.add_track('directed', :label => false, :glyph => :directed_generic, :colour => [0,1,0])
directed_box_track = my_panel.add_track('directed_box', :label => false, :glyph => :directed_box, :colour => [0,1,0])
triangle_track = my_panel.add_track('triangle', :label => false, :glyph => :triangle, :colour => [1,0,0])
spliced_track = my_panel.add_track('spliced', :label => false, :glyph => :spliced, :colour => [1,0,0])
directed_spliced_track = my_panel.add_track('directed_spliced', :label => false, :glyph => :directed_spliced, :colour => [1,0,1])
composite_track = my_panel.add_track('composite_features', :label => false, :glyph => { 'utr5' => :line, 'utr3' => :line, 'cds' => :directed_spliced})
transcript_track = my_panel.add_track('transcripts', :label => true, :glyph => :transcript)

generic_track.add_feature(Bio::Feature.new('clone', '250..375'), :label => 'clone1', :link => 'http://www.newsforge.com', :colour => [0.5,0.8,0.2])
generic_track.add_feature(Bio::Feature.new('clone', '54..124'), :label => 'clone2', :link => 'http://www.thearkdb.org')
generic_track.add_feature(Bio::Feature.new('clone', '100..449'), :label => 'clone3', :link => 'http://www.google.com')

line_track.add_feature(Bio::Feature.new('utr', 'complement(200..320)'), :label => 'some_utr')
line_track.add_feature(Bio::Feature.new('utr', '355..480'), :link => 'http://www.zdnet.co.uk')

line_with_handles_track.add_feature(Bio::Feature.new('utr', 'complement(200..320)'))
line_with_handles_track.add_feature(Bio::Feature.new('utr', '355..480'), :link => 'http://www.zdnet.co.uk')

directed_track.add_feature(Bio::Feature.new('primer', '50..60'), :link => 'http://www.google.com')
directed_track.add_feature(Bio::Feature.new('primer', 'complement(80..120)'), :link => 'http://www.sourceforge.net')

directed_box_track.add_feature(Bio::Feature.new('primer', '50..60'), :link => 'http://www.google.com')
directed_box_track.add_feature(Bio::Feature.new('primer', 'complement(80..120)'), :link => 'http://www.sourceforge.net')

triangle_track.add_feature(Bio::Feature.new('snp', '56'))
triangle_track.add_feature(Bio::Feature.new('snp', '103'), :link =>'http://digg.com')

spliced_track.add_feature(Bio::Feature.new('spliced', 'join(34..52,109..183)'), :link =>'http://news.bbc.co.uk')
spliced_track.add_feature(Bio::Feature.new('spliced', 'complement(join(170..231,264..299,350..360,409..445))'), :label => 'anonymous')
spliced_track.add_feature(Bio::Feature.new('spliced', 'join(134..152,209..283)'))

directed_spliced_track.add_feature(Bio::Feature.new('cds', 'join(34..52,109..183)'), :link => 'http://www.vrtnieuws.net')
directed_spliced_track.add_feature(Bio::Feature.new('cds', 'complement(join(170..231,264..299,350..360,409..445))'), :link => 'http://bioinformatics.roslin.ac.uk')
directed_spliced_track.add_feature(Bio::Feature.new('cds', 'join(134..152,209..283)'))

box_track.add_feature(Bio::Feature.new('clone', '250..375'), :link  => 'http://www.newsforge.com')
box_track.add_feature(Bio::Feature.new('clone', '54..124'), :link  => 'http://www.thearkdb.org')
box_track.add_feature(Bio::Feature.new('clone', '100..449'), :link  => 'http://www.google.com')

transcript1_utr5 = Bio::Feature.new('utr5', '100..150')
transcript1_cds = Bio::Feature.new('cds', 'join(150..225, 250..275, 310..330)')
transcript1_utr3 = Bio::Feature.new('utr3', '330..375')
transcript2_utr5 = Bio::Feature.new('utr5', 'complement(330..375)')
transcript2_cds = Bio::Feature.new('cds', 'complement(join(150..225, 250..275, 310..330))')
transcript2_utr3 = Bio::Feature.new('utr3', 'complement(100..150)')

transcript1 = Bio::Feature.new('transcript', 'join(100..150, 150..225, 250..275, 310..330, 330..375)', [], nil, [transcript1_utr5,transcript1_cds,transcript1_utr3])
transcript2 = Bio::Feature.new('transcript', 'complement(join(100..150, 150..225, 250..275, 310..330, 330..375))', [], nil, [transcript2_utr5,transcript2_cds,transcript2_utr3])

composite_track.add_feature(transcript1, :label => 'my_transcript')
composite_track.add_feature(transcript2, :label => 'my_reverse_transcript')
transcript_track.add_feature(transcript1, :label => 'my_transcript')
transcript_track.add_feature(transcript2, :label => 'my_reverse_transcript')

my_panel.draw('glyph_showcase.svg')
my_panel.format = :png
my_panel.draw('glyph_showcase.png')
my_panel.format = :pdf
my_panel.draw('glyph_showcase.pdf')
my_panel.format = :ps
my_panel.draw('glyph_showcase.ps')