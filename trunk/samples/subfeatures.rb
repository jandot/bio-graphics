require '../lib/bio-graphics'
my_panel = Bio::Graphics::Panel.new(420, 600)

track = my_panel.add_track('transcripts')
track.glyph = :line

# First make the Bio::Feature objects and then create a Bio::Graphics feature
utr5 = Bio::Feature.new('utr', '100..150')
cds = Bio::Feature.new('cds', 'join(150..225, 250..275, 310..330)')
utr3 = Bio::Feature.new('utr', '330..375')
transcript = Bio::Feature.new('transcript', 'join(100..150, 150..225, 250..275, 310..330, 330..375)', nil, nil, [], nil, [utr5,cds,utr3])

track.add_feature(transcript, 'my_label_a', nil, { 'utr' => :line, 'cds' => :spliced })

# Or do it all in one go
track.add_feature(Bio::Feature.new('mrna', 'complement(join(120..250, 300..350, 375..390))'), 'my_label_b', nil, track.glyph, [0,1,0])

my_panel.draw('subfeatures.png')