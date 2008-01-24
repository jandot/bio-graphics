require '../lib/bio-graphics'
my_panel = Bio::Graphics::Panel.new(700, :width => 600)

track = my_panel.add_track('transcripts')
track.glyph = :directed_spliced

# First make the Bio::Feature objects
# Arguments are:
# * type
# * location
# * qualifiers
# * parent
# * subfeatures
utr5 = Bio::Feature.new('utr', '100..150')
cds = Bio::Feature.new('cds', 'join(150..225, 250..275, 310..330)')
utr3 = Bio::Feature.new('utr', '330..375')

transcript = Bio::Feature.new('transcript', 'join(100..150, 150..225, 250..275, 310..330, 330..375)', [], nil, [utr5,cds,utr3])

# And then create the Bio::Graphics feature
# Arguments are:
# * Bio::Feature object
# * name
# * colour
# * glyphs
track.add_feature(transcript, :label => 'my_label_a', :glyph => { 'utr' => :line, 'cds' => :directed_spliced })

# Or do it all in one go, but then we can't do subfeatures.
track.add_feature(Bio::Feature.new('mrna', 'complement(join(120..250, 300..350, 375..390))'), :label => 'my_label_b', :colour => [0,1,0])

my_panel.draw('subfeatures.png')
