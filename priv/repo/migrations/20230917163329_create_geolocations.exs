defmodule Geolocator.Repo.Migrations.CreateGeolocations do
  use Ecto.Migration

  def change do
    create table(:geolocations, primary_key: false) do
      add :ip_address, :inet, primary_key: true
      add :country_code, :string
      add :country, :string
      add :city, :string
      add :latitude, :string
      add :longitude, :string
      add :mystery_value, :bigint

      timestamps()
    end
  end
end
