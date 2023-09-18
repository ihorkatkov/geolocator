# Geolocator
![CI](https://github.com/ihorkatkov/geolocator/actions/workflows/ci.yml/badge.svg)
![Fly.io | CD](https://github.com/ihorkatkov/geolocator/actions/workflows/cd.yml/badge.svg)


# Table of Contents

* [Introduction](#introduction)
* [Getting Started](#getting-started)
  * [Local Setup](#local-setup)
  * [Docker Setup](#docker-local-setup)
* [Data Model and Schema](#data-schema)
* [Geolocation Parsing](#geolocation-parsnig)
* [REST API Layer](#rest-api-layer)
* [CI/CD pipelines](#cicd-pipelines)


# Introduction
Welcome to the Geolocation project! The project is a test task which fullfils the requirenemnts stated in [vio.com test task](https://github.com/viodotcom/backend-assignment-elixir)

The application is accesible at: https://vio-geolocator.fly.dev

For an in-depth understanding of the developmental thought process, please refer to the comprehensive history of Pull Requests, which include descriptive annotations.


# Getting Started

## Local Setup
Local setup using [asdf](https://github.com/asdf-vm/asdf) assuming one have running Postgress:
```
$ asdf install
$ mix setup
```

This script automates the installation of dependencies and performs database initialization. Additionally, it pre-populates the database with the CSV data specified in the test assignment.


## Docker Local Setup
TBA

# Data Schema
[The database schema](https://github.com/ihorkatkov/geolocator/blob/main/lib/geolocator/geolocations/geolocation.ex) mirrors the model present in the CSV file, designating the ip_address field as the primary key within the Postgres database. To optimize for both storage efficiency and functional robustness, I have chosen to utilize Postgres's INET data type for the ip_address field. This decision not only streamlines storage but also avails us of a comprehensive suite of specialized functions for IP address manipulation.

```elixir
@type t :: %Geolocator.Geolocations.Geolocator{
          city: String.t(),
          country: String.t(),
          country_code: String.t(),
          ip_address: Postgrex.INET.t(),
          latitude: String.t(),
          longitude: String.t(),
          mystery_value: integer()
        }
```

# Geolocation parsnig
In an effort to optimize data ingestion, the CSV parsing [mechanism has been engineered](https://github.com/ihorkatkov/geolocator/blob/main/lib/geolocator/geolocations.ex#L23) using Elixir's Stream module. The parser is designed to transform and batch-insert data into the database, a process that is finely configurable to ensure optimal performance. Notably, this approach has proven highly efficient, even on minimal instance types hosted on fly.io.

To maximize database insertion efficiency, we employ Elixir's low-level Repo.insert_all function. This ensures optimal speed while also updating geolocations that share an existing IP address, thus maintaining data integrity.

While the current implementation is effective, there is an opportunity for performance enhancements through a transition to a GenStage (Flow) architecture. It's worth noting that such a modification could result in higher memory consumption, which should be factored into any decision to proceed with this approach.
```elixir
case CSV.parse_file(path) do
  {:ok, stream} ->
    stream
    |> Stream.chunk_every(@csv_stream_chunk_size)
    |> Flow.from_enumerable()
    |> Flow.partition(stages: 2)
    |> Flow.map(&parse_and_insert_geolocations/1)
    |> generate_parsing_report(started_at)
    |> then(&{:ok, &1})

  {:error, _reason} = error ->
    error
end
```

# REST API Layer
Geolocation entries can be accessed via the following API endpoint: https://vio-geolocator.fly.dev/api/geolocations/your-api-here. The architectural approach for this feature aligns with best practices commonly found in Phoenix-based applications.

To maintain simplicity and expedite development, input parameter validation was custom-engineered. However, for more intricate API requirements in the future, the adoption of Ecto changesets would be considered to enhance validation robustness.

# CI/CD pipelines
Both the Continuous Integration (CI) and Continuous Deployment (CD) pipelines have been meticulously engineered utilizing GitHub Actions.

The CI pipeline incorporates a rigorous set of validations including strict credo checks, test executions, Dialyzer verifications, and formatting assessments, thereby ensuring code quality and maintainability.

The CD pipeline is configured to automatically deploy the application to fly.io upon merging changes into the main branch, facilitating a seamless transition from development to production.