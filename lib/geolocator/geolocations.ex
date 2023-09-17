defmodule Geolocator.Geolocations do
  @moduledoc """
  Geolocations context
  """

  alias Geolocator.Geolocations.Geolocation
  alias Geolocator.Repo

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
end
