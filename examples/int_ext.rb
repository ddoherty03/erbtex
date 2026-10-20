# frozen_string_literal: true

class Integer
  alias_method :times, :*
  def *(other)
    case other
    when DMS
      other * self
    else
      times(other)
    end
  end
end
