require 'scaffold'
require 'fileutils'

class Scaffold::Manifest
    attr_reader :directories, :templates

    # Create all of the files and directories needed.
    def create(plugin)
        directories.unshift(plugin.destination)

        # Make each of the directories.
        Dir.chdir(plugin.destination) do
            mkdirs(plugin)

            evaluate_templates(plugin)
        end
    end

    def evaluate_templates(plugin)
        templates.each do |template|
            source = File.join(plugin.source, template)
            dest = File.join(plugin.destination, template)
            raise "File to be templated already exists at %s" % dest if FileTest.exist?(dest)
            raise "Could not find template at %s" % source unless FileTest.exist?(source)

            content = plugin.evaluate_template(File.read(source))
            File.open(dest, "w") { |f| f.print content }
            puts "created file at %s from template %s" % [dest, source]
        end
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
        directories.each do |dir|
            FileUtils.mkdir_p(dir)
            puts "created directory %s" % dir
        end
    end
end
