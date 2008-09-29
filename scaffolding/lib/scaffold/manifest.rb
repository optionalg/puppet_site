require 'scaffold'

class Scaffold::Manifest
    attr_reader :directories, :templates

    # Create all of the files and directories needed.
    def create(plugin)
    end

    def initialize
        @templates = []
        @directories = []
    end

    # Add a new directory to our manifest.
    def directory(name)
        directories << name
    end

    # Add a new template to our manifest.
    def template(name)
        templates << name
    end

    # Make all of the directories associated with this manifest.
    def mkdirs(base)
        Dir.chdir(base) do
            directories.each { |dir| Dir.mkdir(dir) }
        end
    end
end
