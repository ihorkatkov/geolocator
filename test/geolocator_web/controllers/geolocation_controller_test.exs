defmodule GeolocatorWeb.GeolocationControllerTest do
  use GeolocatorWeb.ConnCase

  alias Geolocator.Geolocations.GeolocationFixture
  alias Geolocator.Repo

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "get /api/geolocation" do
    test "returns 200 and geolocation json when data is found", %{conn: conn} do
      {:ok, geolocation} = create_geolocation()

      conn = get(conn, ~p"/api/geolocations/#{EctoNetwork.INET.decode(geolocation.ip_address)}")

      assert %{
               "city" => "DuBuquemouth",
               "country" => "Nepal",
               "country_code" => "SI",
               "ip_address" => "200.106.141.15",
               "latitude" => "-84.87503094689836",
               "longitude" => "7.206435933364332",
               "mystery_value" => 7_823_011_346
             } = json_response(conn, 200)["data"]
    end

    test "returns 404 when geolocation is not found", %{conn: conn} do
      conn = get(conn, ~p"/api/geolocations/0.0.0.0")
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  defp create_geolocation(attrs \\ %{}) do
    attrs
    |> GeolocationFixture.build_geolocation()
    |> Repo.insert()
  end
end
