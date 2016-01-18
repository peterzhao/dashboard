module Ju
  class TimeConverter
    def self.seconds_in_words(secs)
      [
        [60, :seconds, :second],
        [60, :minutes, :minute],
        [24, :hours, :hour],
        [30, :days, :day],
        [12, :months, :month],
        [100000, :years, :year]
].map{ |count, name, sigular|
        if secs > 0
          secs, n = secs.divmod(count)
          "#{n.to_i} #{ n.to_i == 1 ? sigular : name}"
        end
      }.compact.reverse.first
    end
    
    def self.ago_in_words(epoch_ms)
      seconds_in_words(Time.now.utc.to_i - epoch_ms.to_i/1000)
    end
  end
end
