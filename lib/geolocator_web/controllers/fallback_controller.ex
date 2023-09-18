defmodule GeolocatorWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use GeolocatorWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: GeolocatorWeb.ErrorHTML, json: GeolocatorWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :bad_request, errors}) do
    conn
    |> put_status(400)
    |> put_view(json: GeolocatorWeb.ErrorJSON)
    |> render(:"400", errors)
  end
end
