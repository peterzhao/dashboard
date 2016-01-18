require 'rspec'
require_relative '../../lib/ju' 

describe Ju::TimeConverter do
  it 'should get seconds' do
    expect(Ju::TimeConverter.seconds_in_words(35)).to eq('35 seconds')
    expect(Ju::TimeConverter.seconds_in_words(1)).to eq('1 second')
  end

  it 'should get minutes' do
    expect(Ju::TimeConverter.seconds_in_words(130)).to eq('2 minutes')
    expect(Ju::TimeConverter.seconds_in_words(60)).to eq('1 minute')
    expect(Ju::TimeConverter.seconds_in_words(61)).to eq('1 minute')
  end

  it 'should get hours' do
    expect(Ju::TimeConverter.seconds_in_words(60*60*9 + 60*59)).to eq('9 hours')
    expect(Ju::TimeConverter.seconds_in_words(60*60*1 + 60*59)).to eq('1 hour')
    expect(Ju::TimeConverter.seconds_in_words(60*60*23 + 60*59)).to eq('23 hours')
  end

  it 'should get days' do
    expect(Ju::TimeConverter.seconds_in_words(60*60*24*3 + 60*60*23)).to eq('3 days')
    expect(Ju::TimeConverter.seconds_in_words(60*60*24*1 + 60*60*23)).to eq('1 day')
    expect(Ju::TimeConverter.seconds_in_words(60*60*24*29 + 60*60*23)).to eq('29 days')
  end

  it 'should get months' do
    expect(Ju::TimeConverter.seconds_in_words(60*60*24*30)).to eq('1 month')
    expect(Ju::TimeConverter.seconds_in_words(60*60*24*30*11 + 60*60*24*29)).to eq('11 months')
  end

  it 'should get years' do
    expect(Ju::TimeConverter.seconds_in_words(60*60*24*30*12)).to eq('1 year')
    expect(Ju::TimeConverter.seconds_in_words(60*60*24*30*12*10 + 60*60*24*29)).to eq('10 years')
  end

  it 'should get ago words according to epoch timestamp' do
    expect(Ju::TimeConverter.ago_in_words((Time.now.utc.to_i - 3) * 1000)).to eq('3 seconds')
    expect(Ju::TimeConverter.ago_in_words((Time.now.utc.to_i - 60) * 1000)).to eq('1 minute')
    expect(Ju::TimeConverter.ago_in_words((Time.now.utc.to_i - 60*60*12) * 1000)).to eq('12 hours')
    expect(Ju::TimeConverter.ago_in_words((Time.now.utc.to_i - 60*60*24*3) * 1000)).to eq('3 days')
    expect(Ju::TimeConverter.ago_in_words((Time.now.utc.to_i - 60*60*24*30*2) * 1000).to_s).to eq('2 months')
  end
end
