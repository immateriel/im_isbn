# -*- encoding : utf-8 -*-
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "im_isbn"
    gem.summary = %Q{immatériel.fr ISBN lib}
    gem.description = %Q{immatériel.fr ISBN lib}
    gem.email = "jboulnois@immateriel.fr"
    gem.homepage = "http://github.com/immateriel/im_isbn"
    gem.authors = ["julbouln"]
    gem.files = Dir.glob('lib/**/*') + Dir.glob('data/**/*')

    gem.add_dependency "nokogiri"

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/  20 for additional settings
  end
  Jeweler::GemcutterTasks.new


#require 'rake/testtask'
#Rake::TestTask.new(:test) do |test|
#  test.test_files = FileList.new('test/**/test_*.rb') do |list|
#    list.exclude 'test/test_helper.rb'
#    list.exclude 'test/fixtures/**/*.rb'
#  end
#  test.libs << 'test'
#  test.verbose = true
#end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
