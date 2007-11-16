require '../lib/bio-graphics'

my_panel = Bio::Graphics::Panel.new(500, 1000, true)

generic_track = my_panel.add_track('generic', false)
line_track = my_panel.add_track('line', false, :line, [0,0,1])
line_with_handles_track = my_panel.add_track('line_with_handles', false, :line_with_handles, [1,0,0])
directed_track = my_panel.add_track('directed', false, :directed_generic, [0,1,0])
triangle_track = my_panel.add_track('triangle', false, :triangle, [1,0,0])
spliced_track = my_panel.add_track('spliced', false, :spliced, [1,0,0])
directed_spliced_track = my_panel.add_track('directed_spliced', false, :directed_spliced, [1,0,1])
composite_track = my_panel.add_track('composite_features', false, { 'utr' => :line, 'cds' => :directed_spliced})

generic_track.add_feature(Bio::Feature.new('clone', '250..375'), 'anonymous', 'http://www.newsforge.com')
generic_track.add_feature(Bio::Feature.new('clone', '54..124'), 'anonymous', 'http://www.thearkdb.org')
generic_track.add_feature(Bio::Feature.new('clone', '100..449'), 'anonymous', 'http://www.google.com')

line_track.add_feature(Bio::Feature.new('utr', 'complement(200..320)'), 'anonymous')
line_track.add_feature(Bio::Feature.new('utr', '355..480'), 'anonymous', 'http://www.zdnet.co.uk')

line_with_handles_track.add_feature(Bio::Feature.new('utr', 'complement(200..320)'), 'anonymous')
line_with_handles_track.add_feature(Bio::Feature.new('utr', '355..480'), 'anonymous', 'http://www.zdnet.co.uk')

directed_track.add_feature(Bio::Feature.new('primer', '50..60'), 'anonymous', 'http://www.google.com')
directed_track.add_feature(Bio::Feature.new('primer', 'complement(80..120)'), 'anonymous', 'http://www.sourceforge.net')

triangle_track.add_feature(Bio::Feature.new('snp', '56'), 'anonymous')
triangle_track.add_feature(Bio::Feature.new('snp', '103'), 'anonymous','http://digg.com')

spliced_track.add_feature(Bio::Feature.new('spliced', 'join(34..52,109..183)'), 'anonymous','http://news.bbc.co.uk')
spliced_track.add_feature(Bio::Feature.new('spliced', 'complement(join(170..231,264..299,350..360,409..445))'), 'anonymous')
spliced_track.add_feature(Bio::Feature.new('spliced', 'join(134..152,209..283)'), 'anonymous')

directed_spliced_track.add_feature(Bio::Feature.new('cds', 'join(34..52,109..183)'), 'anonymous', 'http://www.vrtnieuws.net')
directed_spliced_track.add_feature(Bio::Feature.new('cds', 'complement(join(170..231,264..299,350..360,409..445))'), 'anonymous', 'http://bioinformatics.roslin.ac.uk')
directed_spliced_track.add_feature(Bio::Feature.new('cds', 'join(134..152,209..283)'), 'anonymous')

utr5 = Bio::Feature.new('utr', '100..150')
cds = Bio::Feature.new('cds', 'join(150..225, 250..275, 310..330)')
utr3 = Bio::Feature.new('utr', '330..375')

transcript = Bio::Feature.new('transcript', 'join(100..150, 150..225, 250..275, 310..330, 330..375)', [], nil, [utr5,cds,utr3])
composite_track.add_feature(transcript, 'my_transcript')

my_panel.draw('glyph_showcase.png')
