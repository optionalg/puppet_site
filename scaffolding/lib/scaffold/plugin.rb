require 'scaffold'
require 'scaffold/manifest'

class Scaffold::Plugin
    attr_reader :name, :options, :mymanifest

    # Find the path to the code that defines the behaviour of the plugin.
    def code
        File.join(source, "plugin.rb")
    end

    # Where should we install the plugin files?
    def destination
        File.join(Scaffold.basedir, path)
    end

    # Generate our scaffolding.
    def generate
        load()

        require 'fileutils'

        unless FileTest.exist?(destination)
            FileUtils.mkdir_p(destination)
        end

        mymanifest.create(self)
    end

    def initialize(name, *options)
        @source = @mymanifest = nil
        @name = name

        @options = options
    end

    # Load the code that defines how this plugin works.
    def load
        raise LoadError, "Could not find code for plugin %s" % name unless FileTest.exist?(code)

        # A touch hackish, but this saves us a bit of typing and unnecessary structure.
        eval(File.read(code))

        raise "Plugin %s has no manifest; cannot generate" % name unless mymanifest
        raise "Plugin %s has not specified a destination path; cannot generate" % name unless path
    end

    # Create and evaluate our manifest.
    def manifest(&block)
        @mymanifest = Scaffold::Manifest.new
        @mymanifest.instance_eval(&block)
    end

    # Set and/or retrieve the path.
    def path(value = nil)
        if value
            @path = value
        end
        @path
    end

    # Find out where our generator code and such is coming from.
    def source
        unless @source
            unless @source = Scaffold.path.collect { |dir| File.join(dir, name) }.find { |d| FileTest.exist?(d) }
                raise "Could not find source for %s" % name
            end
        end
        @source
    end
end
