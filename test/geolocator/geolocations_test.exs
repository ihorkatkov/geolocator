defmodule Geolocator.GeolocationsTest do
  use Geolocator.DataCase, async: true

  alias Geolocator.Geolocations
  alias Geolocator.Geolocations.Geolocation
  alias Geolocator.Geolocations.GeolocationFixture
  alias Geolocator.Geolocations.ParsingReport

  @file_name "geolocations.csv"
  @csv_data """
  ip_address,country_code,country,city,latitude,longitude,mystery_value
  200.106.141.15,SI,Nepal,DuBuquemouth,-84.87503094689836,7.206435933364332,7823011346
  160.103.7.140,CZ,Nicaragua,New Neva,-68.31023296602508,-37.62435199624531,7301823115
  70.95.73.73,TL,Saudi Arabia,Gradymouth,-49.16675918861615,-86.05920084416894,2559997162
  ,PY,Falkland Islands (Malvinas),,75.41685191518815,-144.6943217219469,0
  125.159.20.54,LI,Guyana,Port Karson,-78.2274228596799,-163.26218895343357,1337885276
  """

  describe "parse_geolocations_from_csv!/1" do
    @tag :tmp_dir
    test "parses geolocations from CSV file and inserts them into the database", %{
      tmp_dir: tmp_dir
    } do
      path = Path.join(tmp_dir, @file_name)
      File.touch(path)
      File.write!(path, @csv_data)

      assert %ParsingReport{
               inserted_count: 4,
               error_count: 1,
               time_elapsed: time_elapsed
             } = Geolocations.parse_geolocations_from_csv!(path)

      assert time_elapsed > 0
    end

    test "returns error when file does not exist" do
      assert {:error, :file_not_found} = Geolocations.parse_geolocations_from_csv!(@file_name)
    end
  end

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
