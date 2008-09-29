Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

require 'scaffold'

describe Scaffold do
    it "should have a class attribute that provides the basedir as the parent directory of the parent directory of the library" do
        base = File.expand_path("#{__FILE__}/../../..")

        Scaffold.basedir.should == base
    end

    it "should set its bin directory to the 'bin' directory relative to the base directory" do
        Scaffold.bindir.should == File.join(Scaffold.basedir, "bin")
    end

    it "should set its scaffold directory to the 'scaffolding' directory relative to the base directory" do
        Scaffold.scaffolddir.should == File.join(Scaffold.basedir, "scaffolding")
    end

    it "should set its lib directory to the 'lib' directory relative to the 'scaffolding' directory" do
        Scaffold.libdir.should == File.join(Scaffold.basedir, "scaffolding", "lib")
    end

    it "should set its search path to the main generators directory and one in the basedir" do
        Scaffold.path.should == [File.join(Scaffold.basedir, "generators"), File.join(Scaffold.scaffolddir, "generators")]
    end
end
