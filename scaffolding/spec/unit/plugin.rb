Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

require 'scaffold'

describe Scaffold::Plugin do
    before do
        @plugin = Scaffold::Plugin.new("foo", "bar")
    end

    it "should require a generator name at initialization" do
        lambda { Scaffold::Plugin.new }.should raise_error(ArgumentError)
    end

    it "should require a name at initialization" do
        lambda { Scaffold::Plugin.new("foo") }.should raise_error(ArgumentError)
    end

    it "should make the generator name available" do
        @plugin.generator.should == "foo"
    end

    it "should make the name available" do
        @plugin.name.should == "bar"
    end

    it "should parse all other arguments as name/value pairs" do
        Scaffold::Plugin.new("foo", "bar", "one=two", "three=four").options.should == {:one => "two", :three => "four"}
    end

    it "should be able to provide its source" do
        @plugin.should respond_to(:source)
    end

    it "should calculate its source as the first directory named after itself in the search path" do
        Scaffold.expects(:path).returns %w{/one /two}
        FileTest.expects(:exist?).with("/one/foo").returns false
        FileTest.expects(:exist?).with("/two/foo").returns true

        @plugin.source.should == "/two/foo"
    end

    it "should fail if its source cannot be found" do
        Scaffold.expects(:path).returns %w{/one /two}
        FileTest.expects(:exist?).with("/one/foo").returns false
        FileTest.expects(:exist?).with("/two/foo").returns false

        lambda { @plugin.source }.should raise_error(RuntimeError)
    end

    it "should pick its code as 'plugin.rb' in its source directory" do
        plugin = @plugin
        plugin.expects(:source).returns "/my/source"
        plugin.code.should == "/my/source/plugin.rb"
    end

    it "should be able to get its path" do
        @plugin.should respond_to(:path)
    end

    it "should set its path if a path is provided and return the path if no argument is provided" do
        plugin = @plugin
        plugin.path("yay")
        plugin.path.should == "yay"
    end

    it "should be able to create a manifest" do
        @plugin.should respond_to(:manifest)
    end

    it "should create a manifest and instance_eval the provided block when creating its manifest" do
        manifest = mock 'manifest'
        Scaffold::Manifest.expects(:new).returns manifest
        manifest.expects(:testing)

        plugin = @plugin
        plugin.manifest { testing() }

        plugin.mymanifest.should equal(manifest)

    end

    it "should be able to load its code" do
        @plugin.should respond_to(:load)
    end

    it "should fail when loading if no code exists" do
        scaffold = @plugin
        scaffold.expects(:source).returns "/my/plugin"

        FileTest.expects(:exist?).with("/my/plugin/plugin.rb").returns false

        lambda { scaffold.load }.should raise_error(LoadError)
    end

    it "should load code by reading in and evaluating the specified file" do
        plugin = @plugin
        plugin.stubs(:code).returns "/my/code.rb"
        FileTest.expects(:exist?).with("/my/code.rb").returns true
        File.expects(:read).with("/my/code.rb").returns "my code"
        plugin.expects(:eval).with "my code"

        plugin.stubs(:mymanifest).returns mock("manifest")
        plugin.stubs(:path).returns "mypath"
        
        plugin.load
    end

    it "should fail if it has no manifest after loading" do
        plugin = @plugin

        lambda { plugin.load }.should raise_error(RuntimeError)
    end

    it "should fail if it has no path after loading" do
        plugin = @plugin
        plugin.stubs(:mymanifest).returns mock('manifest')

        lambda { plugin.load }.should raise_error(RuntimeError)
    end

    it "should know how to calculate its destination" do
        @plugin.should respond_to(:destination)
    end

    it "should calculate its destination by joining the base directory and the plugin instance path" do
        plugin = @plugin
        plugin.expects(:path).returns "yayness"
        Scaffold.expects(:basedir).returns "/mydir"

        plugin.destination.should == "/mydir/yayness"
    end

    it "should be able to generate the scaffolding" do
        @plugin.should respond_to(:generate)
    end

    describe "when generating" do
        before do
            @manifest = stub 'manifest', :create => nil
            @plugin.stubs(:mymanifest).returns @manifest
            @plugin.stubs(:load)

            @plugin.stubs(:destination).returns "/my/path"
        end

        it "should load its code" do
            @plugin.expects(:load)

            @plugin.generate
        end

        it "should use its manifest to create the appropriate files" do
            @plugin.expects(:load)

            @manifest.expects(:create).with(@plugin)

            @plugin.generate
        end

        it "should create its base directory if it does not exist" do
            FileTest.expects(:exist?).with("/my/path").returns false

            FileUtils.expects(:mkdir_p).with("/my/path")

            @plugin.generate
        end
    end

    it "should be able to evaluate a template" do
        @plugin.should respond_to(:evaluate_template)
    end

    it "should pass its binding to ERB to evaluate the template" do
        template = mock 'template'

        ERB.expects(:new).with("my code").returns template

        @plugin.expects(:binding).returns "my binding"
        template.expects(:result).with("my binding").returns "my result"

        @plugin.evaluate_template("my code")
    end
end
