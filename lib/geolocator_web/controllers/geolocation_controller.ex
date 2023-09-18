defmodule GeolocatorWeb.GeolocationController do
  use GeolocatorWeb, :controller

  alias Geolocator.Geolocations
  alias Geolocator.Geolocations.Geolocation

  action_fallback GeolocatorWeb.FallbackController

  def show(conn, params) do
    with {:ok, %{"ip_address" => ip_address}} <- validate_show_params(params),
         %Geolocation{} = geolocation <- Geolocations.get_geolocation(ip_address) do
      render(conn, :show, geolocation: geolocation)
    else
      {:error, :bad_request} ->
        {:error, :bad_request, errors: %{ip_address: "is invalid"}}

      nil ->
        {:error, :not_found}
    end
  end

  defp validate_show_params(params) do
    case EctoNetwork.INET.cast(params["ip_address"]) do
      {:ok, ip_address} ->
        {:ok, %{"ip_address" => ip_address}}

      :error ->
        {:error, :bad_request}
    end
  end
end
