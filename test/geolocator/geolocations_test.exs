defmodule Geolocator.GeolocationsTest do
  use Geolocator.DataCase

  alias Geolocator.Geolocations
  alias Geolocator.Geolocations.Geolocation
  alias Geolocator.Geolocations.GeolocationFixture

  describe "create_geolocations/1" do
    test "creates geolocations" do
      fixture = GeolocationFixture.build_geolocation()

      assert :ok = Geolocations.create_geolocations!([fixture])
      assert %Geolocation{} = geolocation = Geolocations.get_geolocation(fixture.ip_address)
      assert geolocation.ip_address == fixture.ip_address
      assert geolocation.country_code == fixture.country_code
      assert geolocation.country == fixture.country
      assert geolocation.city == fixture.city
      assert geolocation.latitude == fixture.latitude
      assert geolocation.longitude == fixture.longitude
      assert geolocation.mystery_value == fixture.mystery_value
    end

    test "raises if invalid data is provided" do
      params = [%{}]

      assert_raise FunctionClauseError, fn ->
        Geolocations.create_geolocations!(params)
      end
    end
  end

  describe "get_geolocation/1" do
    test "returns geolocation" do
      fixture = GeolocationFixture.build_geolocation()

      assert :ok = Geolocations.create_geolocations!([fixture])
      assert %Geolocation{} = geolocation = Geolocations.get_geolocation(fixture.ip_address)
      assert geolocation.ip_address == fixture.ip_address
      assert geolocation.country_code == fixture.country_code
      assert geolocation.country == fixture.country
      assert geolocation.city == fixture.city
      assert geolocation.latitude == fixture.latitude
      assert geolocation.longitude == fixture.longitude
      assert geolocation.mystery_value == fixture.mystery_value
    end

    test "returns nil if geolocation does not exist" do
      ip_address = %Postgrex.INET{address: {200, 106, 141, 15}, netmask: 32}
      assert is_nil(Geolocations.get_geolocation(ip_address))
    end
  end
end
