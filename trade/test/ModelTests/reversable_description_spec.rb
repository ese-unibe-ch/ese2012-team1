require "test_require"

describe ReversableDescription do
  before(:each) do
    @description = ReversableDescription.new
  end

  it "should have version -1" do
    @description.version.should == -1
  end

  it "should have empty array with descriptions" do
    @description.descriptions.should be_empty
  end

  it "should show empty string" do
    @description.show.should be_like ""
  end

  context "when three versions of the descriptions are added" do
    before(:each) do
      @description_v1 = "Hey"
      @description_v2 = "Hey world!"
      @description_v3 = "Bye!"

      @description.add(@description_v1)
      @description.add(@description_v2)
      @description.add(@description_v3)
    end

    it "should show last added description" do
      @description.show.should be_like @description_v3
    end

    it "should show each description when specified" do
      @description.show_version(1).should be_like @description_v1
      @description.show_version(2).should be_like @description_v2
    end

    it "should travers all descriptions" do
      descriptions = [@description_v1, @description_v2, @description_v3]

      @description.traverse do |version, description|
        description.should be_like descriptions[version-1]
      end
    end

    context "when set another version than last added" do
      before(:each) do
        @description.set_version(2)
      end

      it "should show this version" do
        @description.show.should be_like @description_v2
      end
    end
  end
end