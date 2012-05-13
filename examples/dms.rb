#! /usr/bin/ruby

# A class for maipulating angles expressed as degreed, minutes,
# and seconds.

class DMS
  include Comparable

  attr_reader :degrees, :minutes, :seconds

  @@precision = 4

  def initialize(d, m = 0, s = 0.0)
    @degrees = d.to_i
    @minutes = m.to_i
    @seconds = s.to_f
    self.normalize
  end

  def DMS.from_radians(r)
    if r < 0
      r = -r
      sign = -1
    else
      sign = 1
    end
    deg = r * (360.0 / (2.0 * Math::PI))
    degrees = deg.floor
    min = (deg - degrees) * 60.0
    minutes = min.floor
    seconds = min - minutes
    DMS.new(degrees, minutes, seconds)
  end

  def DMS.precision=(p)
    @@precision = p
  end
  
  def to_s
    "#{@degrees}* #{@minutes}' %0.*f''" % [@@precision, @seconds]
  end

  def to_f
    @degrees.to_f + (@minutes / 60.0) + (@seconds / 3600.0)
  end

  def to_radians
    self.to_f * ((2.0 * Math::PI) / 360.0)
  end

  # If degrees are at well-known values, eppress as radians
  # symbolically, using TeX notation
  def to_radians_tex
    unless @seconds == 0.0 and @minutes == 0
      return "$%0.*f$" % [@@precision, self.to_radians]
    end

    # This gets deg to 0 <= x <= 360, even for negative
    # values of @degrees
    deg = @degrees.divmod(360)[1]
    case deg
    when 0
      "$0$"
    when 30
      "$\\pi/6$"
    when 60
      "$\\pi/3$"
    when 90
      "$\\pi/2$"
    when 120
      "$2\\pi/2$"
    when 150
      "$5\\pi/6$"
    when 180
      "$\\pi$"
    when 210
      "$7\\pi/6$"
    when 240
      "$4\\pi/3$"
    when 270
      "$3\\pi/2$"
    when 300
      "5\\pi/3$"
    when 330
      "11\\pi/6$"
    when 360
      "$2\\pi$"
    else
      "$%0.*f$" % [@@precision, self.to_radians]
    end
  end
      
  def to_tex
    # "$#{@degrees}^\\circ #{@minutes}' %0.*f''$" % [@@precision, @seconds] #"
    "$%02d^\\circ~%02d'~%02.*f''$" % [@degrees, @minutes, @@precision, @seconds] #"
  end
  
  def -@
    DMS.new(-@degrees, @minutes, @seconds)
  end
 
  def +@
    DMS.new(@degrees, @minutes, @seconds)
  end

  def <=>(other)
    self.to_radians <=> other.to_radians
  end

  def +(other)
    seconds = @seconds + other.seconds
    minutes = @minutes + other.minutes
    degrees = @degrees + other.degrees
    DMS.new(degrees, minutes, seconds)
  end

  def -(other)
    r = (self + (-other))
    DMS.new(r.degrees, r.minutes, r.seconds)
  end

  def *(scalar)
    DMS.new(scalar*@degrees, scalar*@minutes, scalar*@seconds)
  end

  def /(scalar)
    DMS.new(@degrees / scalar, @minutes / scalar, @seconds / scalar)
  end

  def sin
    Math.sin(self.to_radians)
  end
  
  def cos
    Math.cos(self.to_radians)
  end
  
  def tan
    Math.tan(self.to_radians)
  end
  
  def sec
    (1.0 / Math.cos(self.to_radians))
  end
  
  def csc
    (1.0 / Math.sin(self.to_radians))
  end
  
  def cotan
    (1.0 / Math.tan(self.to_radians))
  end
  
  # Ensure that seconds and minutes are 0 <= x  < 60.
  # After normalization, only degrees can be negative,
  # which will represent a negative quantity
  def normalize
    q, r  = @seconds.divmod(60.0)
    @seconds = r
    @minutes += q
    q, r = @minutes.divmod(60)
    @minutes = r
    @degrees += q
  end
end

class Fixnum
  alias times *
  def *(dms)
    case dms
    when DMS
      dms * self
    else
      self.times(dms)
    end
  end
end
    
if __FILE__ == $0
  print "Fifty seconds: #{DMS.new(0, 0, 50).to_radians}\n"
  print "One minute: #{DMS.new(0, 1, 0).to_radians}\n"
  print "Fifty seconds: #{DMS.new(0, 0, 50).to_f}\n"
  print "One minute: #{DMS.new(0, 1, 0).to_f}\n"
  print "#{DMS.from_radians(Math::PI / 2.0)}\n"
end
