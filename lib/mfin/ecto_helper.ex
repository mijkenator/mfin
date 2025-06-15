defmodule Mfin.EctoHelper do
  
  def enum(values) do
    Ecto.ParameterizedType.init(Ecto.Enum, values: values)
  end

end
