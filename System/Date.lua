--===========================================================================--
--                                                                           --
--                                System.Date                                --
--                                                                           --
--===========================================================================--

--===========================================================================--
-- Author       :   kurapica125@outlook.com                                  --
-- URL          :   http://github.com/kurapica/PLoop                         --
-- Create Date  :   2016/03/08                                               --
-- Update Date  :   2018/03/15                                               --
-- Version      :   1.0.0                                                    --
--===========================================================================--
if not _G.os then return end

PLoop(function(_ENV)
    namespace "System"

    export { strfind = string.find, strgmatch = string.gmatch }

    ALLOW_TIMEFORMAT = { a = true, A = true, b = true, B = true, c = true, C = true, d = true, D = true, e = true, F = true, g = true, G = true, h = true, H = true, I = true, j = true, m = true, M = true, n = true, p = true, r = true, R = true, S = true, t = true, T = true, u = true, U = true, V = true, w = true, W = true, x = true, X = true, y = true, Y = true, z = true, Z = true }

    --- Represents the time format can be used in date api
    __Sealed__() __Base__(String)
    struct "TimeFormat" {
        function(val, onlyvalid)
            if strfind(val, "*t") then
                return onlyvalid or "the %s can't contains '*t' as time format"
            else
                local hasfmt    = false
                for s in strgmatch(val, "%%(.)") do
                    if ALLOW_TIMEFORMAT[s] then
                        hasfmt  = true
                    else
                        return onlyvalid or "the %s contains invalid time format"
                    end
                end
                if not hasfmt then return "the %s doesn't contains any time formats" end
            end
        end
    }

    --- Represents the date object
    __Final__() __Sealed__()
    class "Date" (function (_ENV)
        extend "ICloneable"

        export {
            date        = os.date,
            time        = os.time,
            diff        = os.difftime,
            pairs       = pairs,
            type        = type,
            getmetatable= getmetatable,
            strfind     = strfind,
            rawset      = rawset,
        }

        local offset    = diff(time(date("*t", 10^8)), time(date("!*t", 10^8)))
        local r2Time    = function (self) self.time = time(self) end
        local r4Time    = function (self) for k, v in pairs(date("*t", self.time)) do rawset(self, k, v) end end

        -----------------------------------------------------------
        --                    static property                    --
        -----------------------------------------------------------
        --- Gets a DateTime object that is set to the current date and time on this computer, expressed as the local time.
        __Static__() property "Now" { get = function() return Date( time() ) end }

        -----------------------------------------------------------
        --                       property                        --
        -----------------------------------------------------------
        --- The year of the date
        property "Year" { type = Integer,   field = "year", handler = r2Time }

        --- The month of the year, 1-12
        property "Month" { type = Integer,  field = "month",handler = function(self, value) r2Time(self) if value < 1 or value > 12 then r4Time(self) end end }

        --- The day of the month, 1-31
        property "Day" { type = Integer,    field = "day",  handler = function(self, value) r2Time(self) if value < 1 or value > 28 then r4Time(self) end end }

        --- The hour of the day, 0-23
        property "Hour" { type = Integer,   field = "hour", handler = function(self, value) r2Time(self) if value < 0 or value > 23 then r4Time(self) end end }

        --- The minute of the hour, 0-59
        property "Minute" { type = Integer, field = "min",  handler = function(self, value) r2Time(self) if value < 0 or value > 59 then r4Time(self) end end }

        --- The Second of the minute, 0-61
        property "Second" { type = Integer, field = "sec",  handler = function(self, value) r2Time(self) if value < 0 or value > 59 then r4Time(self) end end }

        --- The weekday, Sunday is 1
        property "DayOfWeek" { get = function(self) return date("*t", self.time).wday end }

        --- The day of the year
        property "DayOfYear" { get = function(self) return date("*t", self.time).yday end }

        --- Indicates whether this instance of DateTime is within the daylight saving time range for the current time zone.
        property "IsDaylightSavingTime" { get = function(self) return date("*t", self.time).isdst end }

        --- Gets the time that represent the date and time of this instance.
        property "Time" { type = Integer, field = "time", handler = r4Time }

        -----------------------------------------------------------
        --                        method                         --
        -----------------------------------------------------------
        --- Return the diff second for the two Date object
        __Arguments__{ Date }
        function Diff(self, obj) return diff(self.time, obj.time) end

        --- Converts the value of the current DateTime object to its equivalent string representation using the specified format.
        __Arguments__{ Variable.Optional(TimeFormat, "%c") }
        function ToString(self, fmt)
            return date(fmt, self.time)
        end

        --- Converts the value of the current DateTime object to its equivalent UTC string representation using the specified format.
        __Arguments__{ Variable.Optional(TimeFormat, "!%c") }
        function ToUTCString(self, fmt)
            if not strfind(fmt, "^!") then fmt = "!" .. fmt end
            return date(fmt, self.time)
        end

        --- Adds the specified number of years to the value of this instance, and return a new date object
        __Arguments__{ Integer }
        function AddYears(self, years)
            return Date(self.year + years, self.month, self.day, self.hour, self.min, self.sec)
        end

        --- Adds the specified number of months to the value of this instance, and return a new date object
        __Arguments__{ Integer }
        function AddMonths(self, months)
            return Date(self.year, self.month + months, self.day, self.hour, self.min, self.sec)
        end

        --- Adds the specified number of months to the value of this instance, and return a new date object
        __Arguments__{ Integer }
        function AddDays(self, days)
            return Date(self.year, self.month, self.day + days, self.hour, self.min, self.sec)
        end

        --- Adds the specified number of hours to the value of this instance, and return a new date object
        __Arguments__{ Integer }
        function AddHours(self, hours)
            return Date(self.year, self.month, self.day, self.hour + hours, self.min, self.sec)
        end

        --- Adds the specified number of minutes to the value of this instance, and return a new date object
        __Arguments__{ Integer }
        function AddMinutes(self, minutes)
            return Date(self.year, self.month, self.day, self.hour, self.min + minutes, self.sec)
        end

        --- Adds the specified number of seconds to the value of this instance, and return a new date object
        __Arguments__{ Integer }
        function AddSeconds(self, seconds)
            return Date(self.year, self.month, self.day, self.hour, self.min, self.sec + seconds)
        end

        --- Return a Clone of the date oject
        function Clone(self)
            return Date(self.Time)
        end

        -----------------------------------------------------------
        --                      constructor                      --
        -----------------------------------------------------------
        function __new(_, time)
            if type(time) == "table" and getmetatable(time) == nil then
                -- No more check
                return time, true
            end
        end

        __Arguments__{ Variable("time", Integer, true) }
        function Date(self, tm)
            self.time = tm or time()
            return r4Time(self)
        end

        __Arguments__{
            Variable("year",  Integer),
            Variable("month", Integer),
            Variable("day",   Integer),
            Variable("hour",  Integer, true, 12),
            Variable("min",   Integer, true, 0),
            Variable("sec",   Integer, true, 0),
            Variable("utc",   Boolean, true, false)
        }
        function Date(self, year, month, day, hour, min, sec, utc)
            self.year = year
            self.month = month
            self.day = day
            self.hour = hour
            self.min = min
            self.sec = utc and (sec + offset) or sec

            r2Time(self)
            r4Time(self)
        end

        ------------------------------------
        -- Meta-method
        ------------------------------------
        __Arguments__{ Date }
        function __eq(self, obj) return self.time == obj.time end

        __Arguments__{ Date }
        function __lt(self, obj) return self.time < obj.time end

        __Arguments__{ Date }
        function __le(self, obj) return self.time <= obj.time end

        __sub       = Diff
        __tostring  = ToString

        export { Date }
    end)
end)