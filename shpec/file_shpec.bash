source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_cwd
  shpec_cleanup
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

source "$(shpec_cwd)"/../lib/rubsh.bash

describe dirname
  it "returns all the components of filename except the last one" do
    File .dirname '/home/jason'
    assert equal /home "$__"
    # File .dirname /home/jason/poot.txt
    # assert equal /home/jason "$__"
    # File .dirname 'poot.txt' .should == '.'
    # File .dirname '/holy///schnikies//w00t.bin' .should == '/holy///schnikies'
    # File .dirname '' .should == '.'
    # File .dirname '/' .should == '/'
    # File .dirname '/foo/foo' .should == '/foo'
  end
end

# it "returns a String" do
#   File.dirname("foo").should be_kind_of(String)
# end
#
# it "does not modify its argument" do
#   x = "/usr/bin"
#   File.dirname(x)
#   x.should == "/usr/bin"
# end
#
# it "ignores a trailing /" do
#   File.dirname("/foo/bar/").should == "/foo"
# end
#
# it "returns the return all the components of filename except the last one (unix format)" do
#   File.dirname("foo").should =="."
#   File.dirname("/foo").should =="/"
#   File.dirname("/foo/bar").should =="/foo"
#   File.dirname("/foo/bar.txt").should =="/foo"
#   File.dirname("/foo/bar/baz").should =="/foo/bar"
# end
#
# it "returns all the components of filename except the last one (edge cases on all platforms)" do
#     File.dirname("").should == "."
#     File.dirname(".").should == "."
#     File.dirname("./").should == "."
#     File.dirname("./b/./").should == "./b"
#     File.dirname("..").should == "."
#     File.dirname("../").should == "."
#     File.dirname("/").should == "/"
#     File.dirname("/.").should == "/"
#     File.dirname("/foo/").should == "/"
#     File.dirname("/foo/.").should == "/foo"
#     File.dirname("/foo/./").should == "/foo"
#     File.dirname("/foo/../.").should == "/foo/.."
#     File.dirname("foo/../").should == "foo"
# end
#
# it "accepts an object that has a #to_path method" do
#   File.dirname(mock_to_path("/")).should == "/"
# end
#
# it "raises a TypeError if not passed a String type" do
#   lambda { File.dirname(nil)   }.should raise_error(TypeError)
#   lambda { File.dirname(0)     }.should raise_error(TypeError)
#   lambda { File.dirname(true)  }.should raise_error(TypeError)
#   lambda { File.dirname(false) }.should raise_error(TypeError)
# end
