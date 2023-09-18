defmodule Geolocator.Geolocations.Geolocation do
  @moduledoc """
  Represents a geolocation schema.
  Uses INET type for ip_address since Postgres provides more efficient storage mechanism
  for ip addresses, and it also provides a number of useful functions for working with.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias EctoNetwork.INET

  @type t :: %__MODULE__{
          city: String.t(),
          country: String.t(),
          country_code: String.t(),
          ip_address: Postgrex.INET.t(),
          latitude: String.t(),
          longitude: String.t(),
          mystery_value: integer()
        }

  @primary_key {:ip_address, INET, autogenerate: false}

  @fields ~w(ip_address country_code country city latitude longitude mystery_value)a

  schema "geolocations" do
    field :city, :string
    field :country, :string
    field :country_code, :string
    field :latitude, :string
    field :longitude, :string
    field :mystery_value, :integer

    timestamps(type: :naive_datetime_usec)
  end

  @doc false
  def changeset(geolocation, attrs) do
    geolocation
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
