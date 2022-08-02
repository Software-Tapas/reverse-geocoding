# Data Preparation Instructions
1. Download the full planet data from any source (like https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf)
2. Start a PostgreSQL database with the Postgis extension
3. Import the planet data:
  - Install osm2pgsql
  - Run the import command with the default.style file:
	`osm2pgsql --flat-nodes /external-data/cache.txt --multi-geometry --drop --slim -U user -d user --password -H localhost -C 12288 --number-processes 4 --style /external-data/default.style /external-data/planet-latest.osm.pbf`
	- In case the commands fails, please check your available RAM and change the `-C` parameter.

4. Pipe the important data into a new table and index the `way` column:

	```
	-- Create data table
	CREATE TABLE public.place_polygon (
	    osm_id bigint,
	    admin_level integer,
	    area text,
	    boundary text,
	    name text,
	    "name:en" text,
	    "name:de" text,
	    place text,
	    population text,
	    ref text,
	    tourism text,
	    width text,
	    z_order integer,
	    way_area real,
	    way public.geometry(Geometry,3857)
	);
	
	-- Copy and filter data
	INSERT INTO place_polygon (admin_level, area, boundary, name, "name:en", "name:de", place, population, ref, tourism, width, z_order, way_area, way) 
	(SELECT admin_level, area, boundary, name, "name:en", "name:de", place, population, ref, tourism, width, z_order, way_area, way FROM planet_osm_polygon WHERE admin_level > 0 AND name !='');
	
	-- Testing
	EXPLAIN (ANALYZE)
	SELECT name, "name:en" as name_en, "name:de" as name_de, admin_level, way_area from place_polygon
	WHERE ST_CONTAINS(way, ST_Transform(ST_SetSRID(ST_Point(-122.2515363, 37.8695371), 4326), 3857))
	ORDER BY admin_level DESC;
	
	-- Index
	CREATE INDEX index_place_polygon_way ON place_polygon USING gist(way);
	
	-- Cleaning up
	CLUSTER place_polygon USING index_place_polygon_way;
	VACUUM (Full) place_polygon;
	
	```
5. 🏁 Ready to use.
