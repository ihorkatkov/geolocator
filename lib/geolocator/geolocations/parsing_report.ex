defmodule Geolocator.Geolocations.ParsingReport do
  @moduledoc false

  @type t :: %__MODULE__{
          inserted_count: non_neg_integer(),
          error_count: non_neg_integer(),
          time_elapsed_ms: non_neg_integer()
        }

  defstruct inserted_count: 0, error_count: 0, time_elapsed_ms: 0
end
