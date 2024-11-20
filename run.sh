set -e
set -u
duckdb -c "
load spatial;

COPY (
    SELECT
        'Feature' AS type,
        json_object(
            'type', 'Point',
            'coordinates', [COALESCE(longitude, 0), COALESCE(latitude, 0)]
        ) as geometry,
        json_object(
            'fsq_place_id', fsq_place_id,
            'name', name,
            'address', address,
            'locality', locality,
            'region', region,
            'postcode', postcode,
            'admin_region', admin_region,
            'post_town', post_town,
            'po_box', po_box,
            'country', country,
            'date_created', date_created,
            'date_refreshed', date_refreshed,
            'date_closed', date_closed,
            'tel', tel,
            'website', website,
            'email', email,
            'facebook_id', facebook_id,
            'instagram', instagram,
            'twitter', twitter,
            'fsq_category_ids', fsq_category_ids,
            'fsq_category_labels', fsq_category_labels,
            'dt', dt
        ) AS properties
    FROM read_parquet('s3://fsq-os-places-us-east-1/release/dt=2024-11-19/places/parquet/*')
) TO STDOUT (FORMAT json);
" | tippecanoe -o foursquare-os-places-2024-11-20.pmtiles --force -l place -rg --drop-densest-as-needed --extend-zooms-if-still-dropping --maximum-tile-bytes=2500000 --progress-interval=10