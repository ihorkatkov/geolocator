defmodule Geolocator.Geolocations.Geolocation do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias EctoNetwork.INET

  @primary_key {:ip_address, INET, autogenerate: false}

  @fields ~w(ip_address country_code country city latitude longitude mystery_value)a

  schema "geolocations" do
    field :city, :string
    field :country, :string
    field :country_code, :string
    field :latitude, :string
    field :longitude, :string
    field :mystery_value, :integer

    timestamps()
  end

  @doc false
  def changeset(geolocation, attrs) do
    geolocation
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
