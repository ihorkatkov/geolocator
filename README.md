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
* [Authorization](#authorization)


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
[The database schema](https://github.com/ihorkatkov/geolocator/blob/main/lib/geolocator/geolocations/geolocation.ex) is pretty much a mirror of the model in the CSV file. I've set the ip_address field as the primary key in the Postgres database. To be smart about storage and functionality, I'm using Postgres's INET data type for the ip_address. This not only saves space but also gives us a bunch of cool, specialized functions for messing with IP addresses.

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
I've fine-tuned the data input process using Elixir's Stream module for CSV parsing. The parser I've designed transforms the data and batch-inserts it into the database. You can even tweak the settings to get the best performance. This setup performs efficiently, even on smaller cloud instances such as those on fly.io.

To ensure quick database inserts, I utilize Elixir's Repo.insert_all function. This not only speeds things up but also updates any geolocations with the same IP, ensuring data integrity.

While the current setup is solid, there's room for improvement. We could switch to a GenStage (Flow) architecture for potentially faster performance. However, this could use more memory, so that's a factor to consider before making the change.
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
You can get to geolocation entries through this API endpoint: https://vio-geolocator.fly.dev/api/geolocations/your-api-here. I've built this feature to line up with the best practices you'd typically see in Phoenix apps.

To keep things straightforward and speed up the development, I engineered the input parameter validation myself. But if we need more complex validation down the line, I'm considering using Ecto changesets to beef up the robustness.

# CI/CD pipelines
I've carefully set up both the Continuous Integration (CI) and Continuous Deployment (CD) pipelines using GitHub Actions.

In the CI pipeline, I've included a bunch of checks to make sure the code is top-notch. We're talking credo checks, tests, Dialyzer verifications, and even formatting assessments. This way, the code stays clean and easy to work with.

For the CD pipeline, it's automated to deploy the app to fly.io as soon as any changes are merged into the main branch. This makes it super smooth to go from development to live production.\

# Authorization
I skipped the authorization part to keep things simple. But if you're thinking about security, I'd definitely recommend either adding authorization or putting the service in a protected network.
