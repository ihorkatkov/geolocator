defmodule Geolocator.Decorators.TelemetrySpan do
  @moduledoc false

  use Decorator.Define, span: 2

  @spec span(event :: list(atom()), meta :: map()) :: term()
  def span(event, meta, body, _context) do
    quote do
      :telemetry.span(unquote(event), unquote(meta), fn ->
        result = unquote(body)
        {result, unquote(meta)}
      end)
    end
  end
end
