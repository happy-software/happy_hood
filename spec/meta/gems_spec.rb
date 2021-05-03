describe "Custom installed gems" do
  describe "rubillow" do
    it "exists" do
      require "rubillow"
      expect(Object.const_defined?("Rubillow")).to be_truthy
    end
  end
end
