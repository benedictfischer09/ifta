require 'spec_helper'

describe CreateSlotsApi do
  describe "validations" do
    it "should be invalid without a quantity" do
      slots = CreateSlotsApi.new
      expect(slots).to be_invalid
    end

    it 'should be invalid if quantity is not a number' do
      slots = CreateSlotsApi.new quantity: "5"
      expect(slots).to be_invalid
    end

    it "should be valid with a quantity" do
      slots = CreateSlotsApi.new quantity: 3
      expect(slots).to be_valid
    end
  end

  describe 'persist' do
    it 'should raise an error if the request is invalid' do
      slots = CreateSlotsApi.new
      expect{slots.persist!}.to raise_error(Exceptions::BadRequest)
    end

    it 'should increase the number of slots by 4 and return the slots' do
      slots = CreateSlotsApi.new quantity: 4
      result = nil
      expect {result = slots.persist!}.to change { Slot.count }.by(4)
      expect(result.length).to eql(4)
    end
  end
end
