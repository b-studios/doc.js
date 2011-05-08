# ../data.img#1818355:1
require_relative '../lib/configs.rb'

describe Configs, ".new" do  
  it "should throw an error, when trying to instantiate" do
    begin
      Configs.new.should == nil
    rescue NoMethodError
      # Maybe there is a better way for this
      true.should == true
    end
  end    
end

describe Configs, ".set" do
  
  before do
    Configs.clear
  end
  
  context "adding a single property" do
          
    it "should be added as a symbol" do
      Configs.set :foo, 1234      
      Configs.foo.should == 1234
    end
    
    it "should be added as a string" do
      Configs.set "bar", 1234      
      Configs.bar.should == 1234
    end
    
    it "should overwrite existing keys" do
      Configs.set :foo, 456      
      Configs.foo.should == 456
    end
  end
  
  it "should add multiple properties" do 
    Configs.set :prop1 => 1,
                :prop2 => 2,
                :prop3 => 3
    Configs.prop1.should == 1
    Configs.prop2.should == 2
    Configs.prop3.should == 3
  end
end

describe Configs, ".has?" do
  
  before do
    Configs.clear
    Configs.set :foo, 999
  end
  
  it "should find entry by symbol" do
    Configs.has?(:foo).should == true 
  end
  
  it "should find entry by string" do
    Configs.has?('foo').should == true 
  end
  
  it "should not find and existing entry" do
    Configs.has?('foobarbaz').should == false
  end
  
end

describe Configs, ".clear" do

  it "should contain no items after clearing" do
    Configs.set :foo => 4,
                :bar => 5 
    
    Configs.clear
      
    Configs.properties.should == []
    Configs.has?(:foo).should == false    
    Configs.has?(:bar).should == false
  end
end
