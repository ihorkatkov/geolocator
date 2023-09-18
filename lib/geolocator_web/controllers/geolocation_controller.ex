defmodule GeolocatorWeb.GeolocationController do
  use GeolocatorWeb, :controller

  alias Geolocator.Geolocations
  alias Geolocator.Geolocations.Geolocation

  action_fallback GeolocatorWeb.FallbackController

  def show(conn, %{"ip_address" => ip_address}) do
    case Geolocations.get_geolocation(ip_address) do
      %Geolocation{} = geolocation ->
        render(conn, :show, geolocation: geolocation)

      nil ->
        {:error, :not_found}
    end
  end
end
