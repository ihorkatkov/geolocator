defmodule Geolocator.CSV do
  @moduledoc """
  CSV module
  """

  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Parses the given CSV file and returns a stream of maps.
  """
  @spec parse_file(path :: String.t()) :: {:ok, [map()]} | {:error, :file_not_found}
  def parse_file(path) do
    case File.exists?(path) do
      true ->
        stream =
          path
          |> File.stream!()
          |> CSV.parse_stream(skip_headers: false)
          |> transform_row_into_map()

        {:ok, stream}

      false ->
        {:error, :file_not_found}
    end
  end

  defp transform_row_into_map(stream) do
    Stream.transform(stream, nil, fn
      headers, nil -> {[], headers}
      row, headers -> {[Enum.zip(headers, row) |> Map.new()], headers}
    end)
  end
end
