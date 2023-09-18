defmodule GeolocatorWeb.GeolocationJSON do
  alias Geolocator.Geolocations.Geolocation

  @doc """
  Renders a list of geolocations.
  """
  def index(%{geolocations: geolocations}) do
    %{data: for(geolocation <- geolocations, do: data(geolocation))}
  end

  @doc """
  Renders a single geolocation.
  """
  def show(%{geolocation: geolocation}) do
    %{data: data(geolocation)}
  end

  defp data(%Geolocation{} = geolocation) do
    %{
      ip_address: EctoNetwork.INET.decode(geolocation.ip_address),
      country_code: geolocation.country_code,
      country: geolocation.country,
      city: geolocation.city,
      latitude: geolocation.latitude,
      longitude: geolocation.longitude,
      mystery_value: geolocation.mystery_value
    }
  end
end
