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
            @manifest.stubs(:puts)
            @plugin = stub 'plugin', :destination => "/my/dir", :source => "/source/dir"

            Dir.stubs(:chdir).yields
            FileUtils.stubs(:mkdir_p)
        end

        it "should require a scaffold instance" do
            lambda { @manifest.create }.should raise_error(ArgumentError)
        end

        it "should chdir into the destination directory" do
            Dir.expects(:chdir).with("/my/dir")
            @manifest.create(@plugin)
        end

        it "should add the destination to the list of directories" do
            FileUtils.expects(:mkdir_p).with("/my/dir")
            @manifest.create(@plugin)
        end

        it "should create each specified directory relative to the plugin's destination" do
            @manifest.stubs(:directories).returns %w{foo bar test/dir}

            %w{foo bar test/dir}.each { |d| FileUtils.expects(:mkdir_p).with(d) }

            @manifest.create(@plugin)
        end

        it "should log each directory created" do
            @manifest.stubs(:directories).returns %w{foo bar test/dir}

            %w{foo}.each { |d| FileUtils.expects(:mkdir_p).with(d) }

            @manifest.expects(:puts).with("created directory foo")

            @manifest.create(@plugin)
        end

        it "should fail if any listed templates already exist in the destination tree" do
            @manifest.stubs(:templates).returns %w{foo.rb}

            FileTest.expects(:exist?).with("/my/dir/foo.rb").returns true
            lambda { @manifest.create(@plugin) }.should raise_error(RuntimeError)
        end

        it "should fail if any listed templates do not exist in the source dir" do
            @manifest.stubs(:templates).returns %w{foo.rb}

            FileTest.expects(:exist?).with("/source/dir/foo.rb").returns false
            FileTest.expects(:exist?).with("/my/dir/foo.rb").returns false
            lambda { @manifest.create(@plugin) }.should raise_error(RuntimeError)
        end

        it "should use the plugin to evaluate all listed templates" do
            @manifest.stubs(:templates).returns %w{foo.rb}

            FileTest.stubs(:exist?).returns true
            FileTest.stubs(:exist?).with("/my/dir/foo.rb").returns false

            File.expects(:read).with("/source/dir/foo.rb").returns "my code"
            File.stubs(:open)

            @plugin.expects(:evaluate_template).with("my code")

            @manifest.create(@plugin)
        end

        it "should write each evaluated template to the appropriate destination" do
            @manifest.stubs(:templates).returns %w{foo.rb}

            FileTest.stubs(:exist?).returns true
            FileTest.stubs(:exist?).with("/my/dir/foo.rb").returns false

            File.stubs(:read).returns "my code"

            @plugin.expects(:evaluate_template).returns "my result"

            fh = mock 'filehandle'

            File.expects(:open).with("/my/dir/foo.rb", "w").yields(fh)
            
            fh.expects(:print).with "my result"

            @manifest.create(@plugin)
        end

        it "should log the creation of templated files" do
            @manifest.stubs(:templates).returns %w{foo.rb}

            FileTest.stubs(:exist?).returns true
            FileTest.stubs(:exist?).with("/my/dir/foo.rb").returns false

            File.stubs(:read).returns "my code"

            @plugin.expects(:evaluate_template).returns "my result"

            File.stubs(:open)

            @manifest.expects(:puts).with("created file at /my/dir/foo.rb from template /source/dir/foo.rb")

            @manifest.create(@plugin)
        end
    end
end
