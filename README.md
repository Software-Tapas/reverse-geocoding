# Reverse Geocoding Service 
[![Language](https://img.shields.io/badge/Swift-5.6-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-4-F6CBCA.svg)](http://vapor.codes)

## Introduction
For location-based services, it is often useful to display a name for any location. This can be achieved by reverse geocoding. By making use of Open Street Map data this project makes it possible to retrieve a location name for any coordinate worldwide in different languages (currently English and German).

## Usage
### Single coordinate location name
`GET /location/<latitude>/<longitude>`
This is an example response for the *GET* query on `http://localhost:8080/location/52.51/13.40`:

```
{
    "coordinate": {
        "latitude": 52.5099983215332,
        "longitude": 13.3999996185303
    },
    "de": "Mitte, Berlin",
    "en": "Mitte, Berlin"
}
```

### Multi coordiante location name
`POST /location` (POST method due to body content). The body looks like the following:

```
{
    "coordinates": [
        {
            "latitude": 51.796873,
            "longitude": 8.434899
        },
        {
            "latitude": 51.804507,
            "longitude": 8.432158
        }
    ]
}
```
This request will return a nullified coordiante object in the response due to multiple input coordinates.

## Requirements
- Swift 5.6 is used with Vapor 4.
- Postgres with PostGIS is used for data storage and queries.
- Redis is used as a caching layer to improve performance.
- A docker-compose file is placed in the root directory. See the docker section for further steps with docker.

## Data
The following data structure is needed in the table `place_polygon`:

- `name`: String
- `name:de`: String
- `name:en`: String
- `way`: Geometry - Polygon
- `admin_level`: Int
- `way_area`: Double

[Here](./data-preparation/Instructions.md) are instructions to create this table from the Open Street Map data. So the data is not part of this project.

## Installation with Docker
1. Clone this repo.
2. Change the secrets for the database password and change the password file paths in the docker-compose file.
3. Add a PostgreSQL data volume to store the database data on disk if you want to speed up noninitial startups.
4. Run `docker-compose up`.
5. Import the prepared data (see the previous step) into the PostgreSQL database.

The web server also exposes a health endpoint to check if the service is running. The endpoint is available under `GET /health` and returns the response code `200`.

## Environment Variables
- `DB_HOST`
- `DB_PORT`
- `DB_USERNAME`
- `DB_DATABASE`
- `DB_PASSWORD_FILE`
- `DB_PASSWORD` (only used if `DB_PASSWORD_FILE` is not set)
- `REDIS_URL` for the redis server url

## License
This project is available under the AGPL Version 3 license. See the LICENSE file for more info.

## Contribution
You can contribute to this project by submitting a detailed issue or by forking this project and sending a pull request. Contributions of any kind are very welcome :)
