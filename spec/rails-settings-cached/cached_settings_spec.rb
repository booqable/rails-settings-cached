require "spec_helper"

describe RailsSettings::CachedSettings do

  describe '.cache_scope' do

    it 'should define cache scope' do
      now = Time.now
      Time.stub(:now).and_return(now)

      Setting.cache_scope Proc.new { Time.now.to_i }

      setting = Setting.new
      setting.cache_scope.should == now.to_i
    end

    it 'should save and get key from cache' do
      now = Time.now
      Time.stub(:now).and_return(now)
      
      Setting.cache_scope Proc.new { Time.now.to_i }

      Setting['some'] = 'Value'

      Rails.cache.read("#{now.to_i}.settings:some").should == 'Value'
    end

  end

end
