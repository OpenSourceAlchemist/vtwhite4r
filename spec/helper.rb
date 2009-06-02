require "pathname"
begin
  require "bacon"
rescue LoadError
  require "rubygems"
  require "bacon"
end

begin
  if (local_path = Pathname.new(__FILE__).dirname.join("..", "lib", "vtwhite4r.rb")).file?
    require local_path
  else
    require "vtwhite4r"
  end
rescue LoadError
  require "rubygems"
  require "vtwhite4r"
end

Bacon.summary_on_exit

describe "Spec Helper" do
  it "Should bring our library namespace in" do
    Vtwhite4r.should == Vtwhite4r
  end
end


