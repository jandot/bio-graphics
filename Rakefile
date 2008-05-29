# 
# Rakefile.rb
# 
# Copyright (C)::   Jan Aerts <jan.aerts@gmail.com>
# License::         The Ruby License
# 
 

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => :svn_commit

file_list = Dir.glob("lib/**/*.rb")

desc "Create RDoc documentation"
file 'doc/index.html' => file_list do
  puts "######## Creating RDoc documentation"
  system "rdoc --force --title 'Bio::Graphics documentation' -m TUTORIAL TUTORIAL README.DEV lib/"
  tmp_file = File.open('doc/tmp.html', 'w')
  File.open('doc/files/TUTORIAL.html').each do |line|
    line.chomp!
    if line =~ /<\/body>/
      tmp_file.puts '<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">'
      tmp_file.puts '</script>'
      tmp_file.puts '<script type="text/javascript">'
      tmp_file.puts '_uacct = "UA-2131816-4";'
      tmp_file.puts 'urchinTracker();'
      tmp_file.puts '</script>'
    end
    tmp_file.puts line
  end
  File.move('doc/tmp.html', 'doc/files/TUTORIAL.html')
end

desc "An alias for creating the RDoc documentation"
task :rdoc do
  Rake::Task['doc/index.html'].invoke
end

desc "Upload documentation to bio-graphics.rubyforge.org"
task :upload_documentation do
  puts "######## Uploading documentation"
  system "cd doc; scp -r * jandot@rubyforge.org:/var/www/gforge-projects/bio-graphics/"
end

desc "Create a new gem"
file 'bio-graphics-1.0.gem' => file_list do
  puts "######## Creating new gem"
  system "gem build bio-graphics.gemspec"
end

desc "An alias for creating the gem"
task :create_gem do
  Rake::Task['bio-graphics-1.0.gem'].invoke
end

desc "Check SVN status"
task :check_svn_status do
  puts "######## Checking SVN status"
  message = String.new
  message << "# SVN status requires manual intervention\n"
  message << "# For items with '?': either svn add or svn propedit svn:ignore\n"
  message << "# For items with '~': don't know yet\n"
  message << "# Please see http://svnbook.red-bean.com/en/1.4/svn-book.html#svn.ref.svn.c.status"
  
  output = `svn status`
  puts output

  allowed_status = ['A','D','M','R','X','I'] # See http://svnbook.red-bean.com/en/1.4/svn-book.html#svn.ref.svn.c.status
  
  output.each do |line|
    status = line.slice(0,1)
    if ! allowed_status.include?(status)
      raise message
    end
  end
end

desc "Check if SVN updates available"
task :check_svn_update do
  puts "######## Checking SVN update"
  output = `svn update`
  puts output
  if output !~ /^At revision [0-9]/
    raise "Please update your working copy first"
  end
end

desc "Commit to SVN repository"
task :svn_commit => [:check_svn_update, :check_svn_status, :create_gem, :rdoc] do
  puts "######## Doing SVN commit"
  system 'svn commit'
end
