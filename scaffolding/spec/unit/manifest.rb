Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

require 'scaffold/manifest'

describe Scaffold::Manifest do
    before do
        @manifest = Scaffold::Manifest.new
    end

    it "should allow addition of a directory" do
        lambda { @manifest.directory "foo" }.should_not raise_error
    end

    it "should return added directories when asked" do
        @manifest.directory "foo"
        @manifest.directory "foo/bar"

        @manifest.directories.should == %w{foo foo/bar}
    end

    it "should allow addition of a template" do
        lambda { @manifest.template "foo" }.should_not raise_error
    end

    it "should return added templates when asked" do
        @manifest.template "foo"
        @manifest.template "bar"

        @manifest.templates.should == %w{foo bar}
    end

    describe "when creating" do
        before do
            @manifest = Scaffold::Manifest.new
            @plugin = stub 'plugin'
        end

        it "should require a scaffold instance" do
            lambda { @manifest.create }.should raise_error(ArgumentError)
        end

        it "should create each specified directory relative to the scaffold's base directory"
    end
end
