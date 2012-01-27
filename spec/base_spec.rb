require 'spec_helper'
describe PassiveResource::Base, "#new" do
  it "should return a PassiveResource::Base instance" do
    instance = PassiveResource::Base.new
    instance.class.to_s.should eq('PassiveResource::Base')
  end
  
  it "should define methods as specified in the hash" do
    instance = PassiveResource::Base.new(:name => 'grady')
    instance.name.should eq('grady')
  end
  
  it "should nest PassiveResource::Base objects" do
    instance = PassiveResource::Base.new(:location => {:city => 'Orlando'})
    instance.location.class.to_s.should eq('PassiveResource::Base')
  end
  
  it "should nest PassiveResource::Base objects within collections" do
    instance = PassiveResource::Base.new(:cities => [{:city => 'Orlando'}, {:city => 'Greenwood'}])
    instance.cities.all? {|item| item.is_a?(PassiveResource::Base)}.should eq(true)
  end
  
  it "should respond to Hash methods" do
    instance = PassiveResource::Base.new(:name => 'grady')
    PassiveResource::Base::HASH_METHODS.all? {|m| instance.respond_to?(m)}.should eq(true)
  end
  
  it "should respond to created methods" do
    instance = PassiveResource::Base.new(:name => 'grady')
    instance.respond_to?('name').should eq(true)
  end
  
  it "should raise exception for unprocessable objects" do
    lambda { PassiveResource::Base.new(nil) }.should raise_error(PassiveResource::ParseError)
  end
end
  
describe PassiveResource::Base, "#seedling" do
  it "should have a seedling equal to the hash" do
    instance = PassiveResource::Base.new(:name => 'grady')
    instance.seedling['name'].should eq('grady')
  end
end

describe PassiveResource::Base, "#many" do
  it "should return a collection of PassiveResource::Base objects" do
    instances = PassiveResource::Base.many(:cities => [{:city => 'Orlando'}, {:city => 'Greenwood'}])
    instances.all? {|item| item.is_a?(PassiveResource::Base)}.should eq(true)
  end
end

describe PassiveResource::Base, "#inspect" do
  it "should return the seedling to_s" do
    instance = PassiveResource::Base.new(:name => 'grady')
    instance.inspect.should eq("{\"name\"=>\"grady\"}")
  end
end