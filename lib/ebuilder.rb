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
		rm_output = `rm -rf ebin/*`
		puts rm_output unless rm_output.empty?
	end

  # task: compile
  
	desc 'compile', 'compile all source code'
	def compile
		clean
		
		erlc_output = `erlc -o ebin/ -I include/ src/*.erl test/*.erl`
		puts erlc_output unless erlc_output.empty?
		
		cp_output = `cp src/*.app ebin/`
		puts cp_output unless cp_output.empty?
	end
	
  # task: doc
  
	desc 'doc', 'generate edoc for all modules'
	def doc
		Dir.glob(File.expand_path('src/*.erl')).each do |filename|
			erl_output = `erl -noshell -run edoc file src/#{File.basename(filename)} -run init stop`
			puts erl_output unless erl_output.empty?
		end

		mv_output = `mv src/*.html doc/`
		puts mv_output unless mv_output.empty?

		Dir.glob(File.expand_path('test/*.erl')).each do |filename|
			erl_output = `erl -noshell -run edoc file test/#{File.basename(filename)} -run init stop`
			puts erl_output unless erl_output.empty?
		end
		
		mv_output = `mv test/*.html doc/`
		puts mv_output unless mv_output.empty?
	end
	
  # task: test
  
	desc 'test', 'run a EUnit tests'
  method_option :application, :type => :string, :required => false, :aliases => "-a"
  method_option :dependencies, :type => :boolean, :required => false, :aliases => "-d"
  method_option :mnesia, :type => :boolean, :required => false, :aliases => "-m"
	def test(name)
	  application = "-s #{options.application}" if options.application
	  dependencies = "deps/*/ebin/" if options.dependencies?
	  mnesia = "-mnesia dir '\"db/dev\"'" if options.mnesia?
	  
		erl_output = `erl -pa ebin/ #{dependencies} #{application} #{mnesia} -run #{name} test -run init stop`
		puts erl_output unless erl_output.empty?
	end
end