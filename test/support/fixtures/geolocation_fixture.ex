defmodule Geolocator.Geolocations.GeolocationFixture do
  @moduledoc """
  Geolocation fixture module
  """

  alias Geolocator.Geolocations.Geolocation

  @doc """
  Builds a fixture of geolocation with the given `attrs`.
  """
  def build_geolocation(attrs \\ %{}) do
    geolocation = %Geolocation{
      ip_address: %Postgrex.INET{address: {200, 106, 141, 15}, netmask: 32},
      country_code: "SI",
      country: "Nepal",
      city: "DuBuquemouth",
      latitude: "-84.87503094689836",
      longitude: "7.206435933364332",
      mystery_value: 7_823_011_346
    }

    Map.merge(geolocation, attrs)
  end
end
