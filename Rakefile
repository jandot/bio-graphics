# 
# Rakefile.rb
# 
# Copyright (C)::   Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::         The Ruby License
# 
 

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => :svn_commit

desc "Create RDoc documentation"
task :rdoc do
  puts "######## Creating RDoc documentation"
  system "rdoc -m TUTORIAL TUTORIAL README.DEV lib/"
end

desc "Create a new gem"
task :create_gem do
  puts "######## Creating new gem"
  system "gem build bio-graphics.gemspec"
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
