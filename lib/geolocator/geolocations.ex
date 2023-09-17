defmodule Geolocator.Geolocations do
  @moduledoc """
  Geolocations context
  """

  alias Geolocator.CSV
  alias Geolocator.Geolocations.Geolocation
  alias Geolocator.Geolocations.ParsingReport
  alias Geolocator.Repo

  @csv_stream_chunk_size 1000

  @doc """
  Parses geolocations from the given CSV file and inserts them into the database in batches by #{@csv_stream_chunk_size}.
  Utilizes Stream API to reduce memory consumption.

  ## Example
  iex> Geolocator.Geolocations.parse_geolocations_from_csv!("path/to/file.csv")
  iex> {:ok, %ParsingReport{inserted_count: 4, error_count: 1, time_elapsed_ms: 23}}
  """
  @spec parse_geolocations_from_csv!(String.t()) ::
          {:ok, ParsingReport.t()} | {:error, :file_not_found}
  def parse_geolocations_from_csv!(path) do
    started_at = System.monotonic_time(:millisecond)

    case CSV.parse_file(path) do
      {:ok, stream} ->
        stream
        |> Stream.chunk_every(@csv_stream_chunk_size)
        |> Stream.map(&parse_and_insert_geolocations/1)
        |> generate_parsing_report(started_at)
        |> then(&{:ok, &1})

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Creates geolocations using low-level `Repo.insert_all/3` for a maximum efficiency.
  Replaces existing geolocations with the same IP address.

  ## Example
  iex> geolocation = %Geolocation{
    ip_address: %Postgrex.INET{address: {200, 106, 141, 15}, netmask: 32},
    country_code: "SI",
    country: "Nepal",
    city: "DuBuquemouth",
    latitude: "-84.87503094689836",
    longitude: "7.206435933364332",
    mystery_value: 7_823_011_346
  }
  iex> Geolocator.Geolocations.create_geolocations([geolocation])
  """
  @spec create_geolocations!([Geolocation.t()]) :: :ok
  def create_geolocations!(geolocations) do
    attrs = convert_to_attrs(geolocations)

    {_insertetions_count, _returning} =
      Repo.insert_all(Geolocation, attrs,
        on_conflict: :replace_all,
        conflict_target: :ip_address
      )

    :ok
  end

  @spec convert_to_attrs([Geolocation.t()]) :: [map()]
  defp convert_to_attrs(geolocations) do
    Enum.map(geolocations, fn %Geolocation{} = geolocation ->
      geolocation
      |> Map.from_struct()
      |> Map.drop([:__meta__])
      |> Map.put(:inserted_at, NaiveDateTime.utc_now())
      |> Map.put(:updated_at, NaiveDateTime.utc_now())
    end)
  end

  @doc """
  Returns a geolocation with the given `ip_address` or `nil` if not found.

  ## Example
  iex> Geolocator.Geolocations.get_geolocation(%Postgrex.INET{address: {200, 106, 141, 15}, netmask: 32})
  iex> %Geolocation{
    ip_address: %Postgrex.INET{address: {200, 106, 141, 15}, netmask: 32},
    country_code: "SI",
    country: "Nepal",
    city: "DuBuquemouth",
    latitude: "-84.87503094689836",
    longitude: "7.206435933364332",
    mystery_value: 7_823_011_346
  }
  """
  @spec get_geolocation(Postgrex.INET.t()) :: Geolocation.t() | nil
  def get_geolocation(ip_address) do
    Repo.get_by(Geolocation, ip_address: ip_address)
  end

  defp parse_and_insert_geolocations(rows) do
    %{geolocations: geolocations, errors: errors} =
      Enum.reduce(rows, %{geolocations: [], errors: []}, &parse_geolocation/2)

    :ok = create_geolocations!(geolocations)

    %ParsingReport{inserted_count: length(geolocations), error_count: length(errors)}
  end

  defp parse_geolocation(row, acc) do
    case Geolocation.changeset(%Geolocation{}, row) do
      %Ecto.Changeset{valid?: true} = changeset ->
        geolocation = Ecto.Changeset.apply_action!(changeset, :transform)
        %{acc | geolocations: [geolocation | acc.geolocations]}

      %Ecto.Changeset{valid?: false} = changeset ->
        %{acc | errors: [changeset | acc.errors]}
    end
  end

  defp generate_parsing_report(results, started_at) do
    results
    |> Enum.reduce(%ParsingReport{}, fn
      %{inserted_count: inserted_count, error_count: error_count}, %ParsingReport{} = report ->
        %{
          report
          | inserted_count: report.inserted_count + inserted_count,
            error_count: report.error_count + error_count
        }
    end)
    |> Map.put(:time_elapsed_ms, System.monotonic_time(:millisecond) - started_at)
  end
end
