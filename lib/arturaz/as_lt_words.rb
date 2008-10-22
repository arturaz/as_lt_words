module Arturaz
  module AsLtWords
    module IntegerExtensions
      module InstanceMethods
        # Returns _self_ as lithuanian string.
        # 3 arguments used for:
        # * 1, 21, 31, 41...
        # * 10..20, 30, 40...
        # * everything else
        # * 0 items. Uses tens for it if not supplied
        #
        # You can provide custom strings where %d will be replaced by
        # your number. Also you MUST escape % by using %%.
        #
        # If you want to use custom strings but there is no %d in them,
        # you must pass :custom => true as last argument.
        def as_lt_words(ones, tens, plural, zeroes=nil, options={})          
          last = self - (self / 10) * 10
          if self == 0 and not zeroes.nil?
            str = zeroes
          elsif last == 0 || (10..20).include?(self)
            str = tens
          elsif last == 1
            str = ones
          else
            str = plural
          end
          
          if options[:custom] or str.include?("%d")
            str % self
          else
            "%d #{str}" % self
          end
        end

        # Return _self_ as lithuanian second string
        def as_lt_seconds(variation=:ago)
          case variation 
          when :ago
            as_lt_words("sekundę", "sekundžių", "sekundes")
          when :noun
            as_lt_words("sekundė", "sekundžių", "sekundės")
          when :since
            as_lt_words("sekundės", "sekundžių", "sekundžių")
          end
        end

        # Return _self_ as lithuanian minute string
        def as_lt_minutes(variation=:ago)
          case variation 
          when :ago
            as_lt_words("minutę", "minučių", "minutes")
          when :noun
            as_lt_words("minutė", "minučių", "minutės")
          when :since
            as_lt_words("minutės", "minučių", "minučių")
          end
        end

        # Return _self_ as lithuanian hour string
        def as_lt_hours(variation=:ago)
          case variation 
          when :ago
            as_lt_words("valandą", "valandų", "valandas")
          when :noun
            as_lt_words("valanda", "valandų", "valandos")
          when :since
            as_lt_words("valandos", "valandų", "valandų")
          end
        end

        # Return _self_ as lithuanian day string
        def as_lt_days(variation=:ago)
          case variation 
          when :ago
            as_lt_words("dieną", "dienų", "dienas")
          when :noun
            as_lt_words("diena", "dienų", "dienos")
          when :since
            as_lt_words("dienos", "dienų", "dienų")
          end
        end

        # Return _self_ as lithuanian week string
        def as_lt_weeks(variation=:ago)
          case variation 
          when :ago
            as_lt_words("savaitę", "savaičių", "savaites")
          when :noun
            as_lt_words("savaitė", "savaičių", "savaitės")
          when :since
            as_lt_words("savaitės", "savaičių", "savaičių")
          end
        end
      end
    end
  
    module DateExtensions
      module InstanceMethods
        # Gives Lithuanian representation of Date. If passed 
        # :with_week_day => true also adds what weekday is it.
        def to_lt_words(options={})
          str = "%04d m. %s %02d d." % [year, Time::LT_MONTHS[month - 1], day]
          str += ", %s" % Date::DAYNAMES[wday].downcase \
            if options[:with_week_day]
          str
        end
      end
    end
    
    module TimeExtensions
      module InstanceMethods
        LT_MONTHS = %w[sausio vasario kovo balandžio gegužės birželio liepos 
        rugpjūčio rugsėjo spalio lapkričio gruodžio]

        # Returns time as word representation.
        #
        # options:
        #   :time - add time?
        #   :seconds - add seconds?
        def to_lt_words(options={})
          options = {:time => true, :seconds => false}.merge(options)

          str = "%04d m. %s %02d d." % [year, LT_MONTHS[month - 1], day]
          if options[:time]
            str += " %02d:%02d" % [hour, min]        
            str += ":%02d" % sec if options[:seconds]
          end

          str
        end
        
        # DEPRECATED - use to_lt_words
        def to_words(options={}); to_lt_words(options); end

        # Return time as lithuanian string. Pass true to _detailed_ to get
        # word and exact time
        def as_lt_words(detailed=false)
          (Time.now > self ? ago_as_lt_words : since_as_lt_words) + 
            (detailed ? " (#{to_words(:time => true)})" : '')
        rescue ArgumentError
          to_words :time => true
        end

        def ago_as_lt_words
          "prieš " + self.class.distance_in_lt_words(Time.now - self, :ago)
        end

        def since_as_lt_words
          "už " + self.class.distance_in_lt_words(self - Time.now, :since)
        end
      end

      module ClassMethods    
        # Returns distance in _seconds_ in lithuanian words. Max arg: 31 days.
        def distance_in_lt_words(seconds, variation=:noun)
          seconds = seconds.round
          if seconds < 60
            return seconds.as_lt_seconds(variation)
          else
            minutes = seconds / 60
            seconds -= minutes * 60
            if minutes < 60
              return minutes.as_lt_minutes(variation) + 
                (seconds == 0 ? '' : ' ir ' + seconds.as_lt_seconds(variation))
            else
              hours = minutes / 60
              minutes -= hours * 60
              if hours < 24
                return hours.as_lt_hours(variation) + 
                  (minutes == 0 ? '' : ' ir ' + minutes.as_lt_minutes(variation))
              else
                days = hours / 24
                hours -= days * 24
                if days <= 31
                  if days >= 7
                    weeks = days / 7
                    days -= weeks * 7

                    return weeks.as_lt_weeks(variation) + 
                      (days == 0 ? '' : ' ir ' + days.as_lt_days(variation))
                  else              
                    return days.as_lt_days(variation) +
                      (hours == 0 ? '' : ' ir ' + hours.as_lt_hours(variation))
                  end
                else
                  raise ArgumentError.new(
                    "Difference is too big! Try using #to_words.")
                end
              end
            end
          end
        end
      end
    end
  end
end