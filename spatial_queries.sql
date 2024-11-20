-- Area of land zoned for agriculture

select sum(st_area(geom))

from spatial_sql.land_parcels

where zoning like 'A%';



-- Is there a street named Richmond?

select * 

from spatial_sql.street2_centerline

where stname ilike 'Richmond%';

-- ilike is case insensitive



-- How many segments are there for Richmond street? and what is 

--is the total, min and max lengths of these segments

select sum(st_length(geom)) sum_length_m,

count(*) segments_count,

round(max(st_length(geom))::numeric, 2) max_seg_length_m,

round(min(st_length(geom))::numeric, 2) min_seg_length_m

from spatial_sql.street2_centerline

where stname ilike 'richmond%';



-- what is the perimeter of all parcels zoned for agriculture?

select *, round(st_perimeter(geom)::numeric,2) as perimeter_m

from spatial_sql.land_parcels

where zoning ilike 'A%'

order by st_perimeter(geom) desc;



-- Geometry Functions

-- Arenas is currently in wgs 84 while the project crs 26917

-- Transform geometries

-- What land_parcels intersect with Arenas?

select a.*

from spatial_sql.land_parcels a,

spatial_sql.arenas b

where st_intersects(a.geom, st_transform(b.geom,26917));



-- Get lat/long coordinates

select *, st_x(geom) as long, st_y(geom) as lat

from spatial_sql.arenas;



-- Get utm coordinates and lat/long rounded off

select *, round(st_x(st_transform(geom, 26917))::numeric,2) easting,

round(st_y(st_transform(geom, 26917)) :: numeric,2) northing,

round(st_x(geom)::numeric, 6) long,

round(st_y(geom)::numeric, 6) lat

from spatial_sql.arenas;



-- Get the centroid of all polygons

select id, st_centroid(geom) geom

from spatial_sql.land_parcels;



-- Get the centroid of a particular polygon

select id, st_centroid(geom) geom

from spatial_sql.land_parcels

where id=16257;



-- I want to know the srid of the land_parcels layer

select st_srid(geom) from spatial_sql.land_parcels limit 1;



-- I want the Northing/ Easting of the centroid of polygon 77373

select id, 

		st_centroid(geom) geom,

		round(st_y(st_centroid(geom))::numeric, 2) northing, 

		round(st_x(st_centroid(geom)):: numeric, 2) easting

from spatial_sql.land_parcels

where id=16257;

-- Proximity Analysis

-- Both layers are in the same crs - 26917 which is in utm 

-- so coordinates are in northing and easting

--  we can use st_dwithin according to docs:

-- For geography: units are in meters and distance measurement

-- join all community centres to parcels if they ae within 10km of each other


select distinct on (a.id)

					a.*, b.centre,

					st_distance(a.geom, b.geom) as distance_m

from spatial_sql.land_parcels as a

left join spatial_sql.community_centres as b

on st_dwithin(a.geom, b.geom, 10000)

order by a.id, distance_m;



--Proximity Analysis - Create Table AS

create table spatial_sql.parcels_within_10km_OF_community_centres as

select distinct on (a.id)

					a.*, b.centre,

					st_distance(a.geom, b.geom) as distance_m

from spatial_sql.land_parcels as a

left join spatial_sql.community_centres as b

on st_dwithin(a.geom, b.geom, 10000)

order by a.id, distance_m;




