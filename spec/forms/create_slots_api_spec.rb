require 'spec_helper'

describe CreateSlotsApi do
  describe "validations" do
    it "should be invalid without a quantity" do
      slots = CreateSlotsApi.new schedule_id: 3
      expect(slots).to be_invalid
    end

    it 'should be invalid if quantity is not a number' do
      slots = CreateSlotsApi.new quantity: "z", schedule_id: 3
      expect(slots).to be_invalid
    end

    it "should be invalid without a schedule_id or a time_block id" do
      slots = CreateSlotsApi.new quantity: 3
      expect(slots).to be_invalid
    end

    it "should be valid with a quantity and schedule" do
      slots = CreateSlotsApi.new quantity: 3, schedule_id: 1
      expect(slots).to be_valid
    end

    it "should be valid with a quantity and time block id" do
      slots = CreateSlotsApi.new quantity: 3, time_block_id: 1
      expect(slots).to be_valid
    end
  end

  describe 'persist' do
    it 'should raise an error if the request is invalid' do
      slots = CreateSlotsApi.new
      expect{slots.persist!}.to raise_error(Exceptions::BadRequest)
    end

    it 'should increase the number of slots by 4 and and return the slots' do
      conference = FactoryGirl.create(:conference)
      slots = CreateSlotsApi.new quantity: 4, schedule_id: conference.schedule.id
      result = nil
      expect {result = slots.persist!}.to change { conference.schedule.slots.count }.by(4)
      expect(result.length).to eql(4)
    end

    it 'should increase the number of time blocks by 1' do
      conference = FactoryGirl.create(:conference)
      slots = CreateSlotsApi.new quantity: 4, schedule_id: conference.schedule.id
      expect { slots.persist!}.to change { conference.schedule.time_blocks.count }.by(1)
    end

    it 'should increase the number of slots by 4 and return the slots' do
      conference = FactoryGirl.create(:conference_with_3_slots)
      time_block = conference.schedule.time_blocks.first
      slots = CreateSlotsApi.new quantity: 4, time_block_id: time_block.id
      result = nil
      expect {result = slots.persist!}.to change { time_block.slots.count }.by(4)
      expect(result.length).to eql(4)
    end

    it 'should not change the time block count when using an existing time block' do
      conference = FactoryGirl.create(:conference_with_3_slots)
      time_block = conference.schedule.time_blocks.first
      slots = CreateSlotsApi.new quantity: 4, time_block_id: time_block.id
      expect { slots.persist!}.to_not change { conference.schedule.time_blocks.count }
    end
  end
end