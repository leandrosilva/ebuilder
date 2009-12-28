require 'rubygems'
require 'thor'
require 'yaml'

#
# Thor classes, the magic of tasks!
#
class Ebuilder < Thor
  include Thor::Actions
  
  #
  # Setup
  #
  
  def self.source_root
    File.expand_path(File.dirname('.'))
  end
  
  def self.destination_root
    File.expand_path(File.dirname('.'))
  end
  
  #
  # Tasks
  #

  # task: all
  
	desc 'all', 'clean, compile and generate edoc for all modules'
	def all
		clean
		compile
		doc
	end

  # task: clean
  
	desc 'clean', 'clean ebin directory'
	def clean
		`rm -rf ebin/*`
	end

  # task: compile
  
	desc 'compile', 'compile all source code'
	def compile
		clean
		
		`erlc -o ebin/ -I include/ src/*.erl test/*.erl`
		`cp src/*.app ebin/`
	end
	
  # task: doc
  
	desc 'doc', 'generate edoc for all modules'
	def doc
		Dir.glob(File.expand_path('src/*.erl')).each do |filename|
			`erl -noshell -run edoc file src/#{File.basename(filename)} -run init stop`
		end

		`mv src/*.html doc/`

		Dir.glob(File.expand_path('test/*.erl')).each do |filename|
			`erl -noshell -run edoc file test/#{File.basename(filename)} -run init stop`
		end
		
		`mv test/*.html doc/`
	end
	
  # task: test
  
	desc 'test', 'run a EUnit tests'
	def test(name)
		puts `erl -pa ebin/ -noshell -run #{name} test -run init stop`
	end
end