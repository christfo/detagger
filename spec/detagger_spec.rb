require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "ostruct"

describe Detagger do 
    before( :each ) do
        @options = Class.new do
            def bob;     "henry:" end
            def sue;     "mary" end
            def alfy;    "sue:" end
            def jess;    "sue:/bob:some text/bob:text" end
            def david;   "persue:" end
            def kate;    "kate:" end
            def rachel;  "phebs:" end
            def phebs;   "rachel:" end
            def greg;    "re/rachel:/henry:/fdgfd/   " end
            def jenny;   ":alfy:sue:sue:david:" end
        
            def fred_;   "fred:" end
            def al;      "al" end
            def alfred;  "BAD" end
            def bert;    "al:fred:/al:fred_:" end

            def jim;    "" end
            def soph;   nil end
            def matt;   "soph:" end
            def mike;   "sue:soph:sue:jim:" end

            include Detagger
        end.new
        # @options.extend Detagger
    end


    it "has a detag mand drill_down_ref method" do
        @options. should respond_to :detag
        @options. should respond_to :drill_down_ref
    end

    it "will respond to detag* and raw* mehtods" do
        @options. should respond_to :detag_bob
        @options. should respond_to :raw_bob
    end

    it "will give a value for inputs" do
        @options.bob.should  == "henry:"
        @options.sue.should  == "mary"
    end

    it "will raise when a method is missing" do
        lambda { @options.broken }.should raise_error
    end

    it "will late bind 'tag' references" do
        @options.detag_alfy.should_not == "sue:"
        @options.detag_alfy.should     == @options.sue
    end

    it "will provide readers for raw values  of late bind 'tag' references" do
        @options.raw_alfy.should     == "sue:"
        @options.raw_alfy.should_not == @options.sue
    end

    it "will support multiple tags in a value" do
        @options.detag_jess.should == "mary/henry:some text/henry:text"
    end

    it "will pass through unrecognised tags a plain text" do
        @options.detag_david.should == "persue:"
    end

    it "will raise when circular references are found" do
        lambda { @options.detag_kate }.should raise_error "Self Reference"
        lambda { @options.detag_phebs }.should raise_error "Circular Reference"
        lambda { @options.detag_greg }.should raise_error "Circular Reference"
    end

    it "will not be confused by multiple same tags" do
        @options.detag_jenny.should == ":marymarymarypersue:"
    end

    it "will not compose new tags from resolved tags" do
        @options.detag_bert.should_not == "BAD/BAD"
        @options.detag_bert.should     == "alfred:/alfred:"
    end

    it "will gracefully handle flag values" do
        @options.raw_jim.should    == ""
        @options.raw_soph.should   == nil
        @options.detag_soph.should == nil
        @options.detag_matt.should == nil
    end

    it "will absorbe nil values inside a string" do
        @options.detag_mike.should == "marymary"
    end

    it "will search for tags down a cahin of objects" do
        second      = OpenStruct.new
        second.nick = "Found!"
        @options.set_detag_chain( @options, second )
        @options.detag_nick.should == "Found!"
    end

    it "will look for tags in strict chain order" do
        second      = OpenStruct.new
        second.sue  = "not this one"
        @options.set_detag_chain( @options, second )
        @options.detag_sue.should_not  == "not this one"
        @options.detag_sue.should  == "mary"
    end

    it "will compose missing tags from both sources" do
        second       = OpenStruct.new
        second.henry = "correct"
        @options.set_detag_chain( @options, second )
        @options.detag_bob.should  == "correct"
    end
end
