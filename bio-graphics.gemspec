require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = 'bio-graphics'
  s.version = "1.4"

  s.author = "Jan Aerts"
  s.email = "jan.aerts@gmail.com"
  s.homepage = "http://bio-graphics.rubyforge.org/"
  s.summary = "Library for visualizing genomic regions"

  s.platform = Gem::Platform::RUBY
  s.files = Dir.glob("{doc,lib,samples,test,images}/**/*").delete_if {|item| item.include?("SVN") || item.include?("rdoc")}
  s.files.concat ["TUTORIAL"]

  # s.rdoc_options << '--exclude' << '.'
  s.has_rdoc = true

  s.add_dependency('bio', '>=1')

  s.require_path = 'lib'
  s.autorequire = 'bio-graphics'
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end
