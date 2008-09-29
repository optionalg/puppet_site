# The base scaffolding class.
class Scaffold
    require 'scaffold/manifest'
    require 'scaffold/plugin'

    BASEDIR = File.expand_path("#{__FILE__}/../..")

    def self.basedir
        BASEDIR
    end

    def self.directory(*args)
        File.join(basedir, *args)
    end

    def self.bindir
        directory "bin"
    end

    def self.path
        [directory("generators"), File.join(scaffolddir, "generators")]
    end

    def self.scaffolddir
        directory "scaffolding"
    end

    def self.libdir
        directory "scaffolding", "lib"
    end
end
