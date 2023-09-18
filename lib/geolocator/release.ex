defmodule Geolocator.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :geolocator
  @prepopulate_url "https://raw.githubusercontent.com/viodotcom/backend-assignment-elixir/master/cloud_data_dump.csv"
  @prepopulate_path "seeds.csv"

  def prepopulate(url \\ @prepopulate_url, path \\ @prepopulate_path) do
    load_app()

    :ok = write_to_csv_file(path, url)
    {:ok, report} = Geolocator.Geolocations.parse_geolocations_from_csv(path)
    :ok = remove_file(path)

    report
  end

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp write_to_csv_file(path, url) do
    file = File.open!(path, [:write, :exclusive])
    request = Finch.build(:get, url)

    Finch.stream(request, Geolocator.Finch, nil, fn
      {:status, _status}, _ ->
        :ok

      {:headers, _headers}, _ ->
        :ok

      {:data, data}, _ ->
        IO.binwrite(file, data)
    end)

    File.close(file)
  end

  defp remove_file(path) do
    File.rm(path)
  end
end
