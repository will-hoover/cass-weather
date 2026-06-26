// create namespace and specify how many datacenters
CREATE KEYSPACE IF NOT EXISTS weather_ml
WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3
};

// location information
CREATE TABLE IF NOT EXISTS locations (
    region_id TEXT PRIMARY KEY,
    latitude DOUBLE,
    longitude DOUBLE,
    elevation DOUBLE,
    timezone TEXT
);

// store raw data regarding rainfall 
CREATE TABLE IF NOT EXISTS rainfall_raw_data (
    station_id text,
    year_week text,
    observation_time timestamp,
    latitude double,
    longitude double,
    temperature_2m double,
    relative_humidity_2m double,
    dew_point_2m double,
    precipitation double,
    rain double,
    snowfall double,
    snow_depth double,
    surface_pressure double,
    pressure_msl double,
    cloud_cover double,
    cloud_cover_low double,
    cloud_cover_mid double,
    cloud_cover_high double,
    wind_speed_10m double,
    wind_speed_100m double,
    wind_direction_10m double,
    wind_direction_100m double,
    wind_gusts_10m double,
    soil_temperature_0_7 double,
    soil_temperature_7_28 double,
    soil_temperature_28_100 double,
    soil_temperature_100_255 double,
    soil_moisture_0_7 double,
    soil_moisture_7_28 double,
    soil_moisture_28_100 double,
    soil_moisture_100_255 double,
    weather_code int, // possibly use for verifying prediction
    ingestion_timestamp timestamp,
    PRIMARY KEY (
        (station_id, year_week),
        observation_time
    )
)
WITH CLUSTERING ORDER BY (observation_time ASC)
AND compaction = {
    'class': 'TimeWindowCompactionStrategy',
    'compaction_window_unit': 'DAYS',
    'compaction_window_size': '7'
};

// features/attributes to feed into ML pipelines
CREATE TABLE IF NOT EXISTS rainfall_attributes (
    station_id text,
    year_week text,
    feature_timestamp timestamp,
    temp_current double,
    humidity_current double,
    dewpoint_current double,
    precip_last_1h double,
    precip_last_3h double,
    precip_last_6h double,
    precip_last_12h double,
    precip_last_24h double,
    rain_last_24h double,
    rain_last_48h double,
    rain_last_72h double,
    avg_temp_24h double,
    avg_temp_48h double,
    avg_temp_72h double,
    avg_humidity_24h double,
    avg_humidity_48h double,
    pressure_change_3h double,
    pressure_change_6h double,
    pressure_change_12h double,
    pressure_change_24h double,
    avg_pressure_24h double,
    avg_cloud_cover_24h double,
    avg_cloud_cover_72h double,
    avg_wind_speed_24h double,
    max_wind_gust_24h double,
    avg_soil_moisture_24h double,
    rainfall_next_24h double,
    rainfall_label int,
    feature_generation_time timestamp,
    PRIMARY KEY (
        (station_id, year_week),
        feature_timestamp
    )
)
WITH CLUSTERING ORDER BY (feature_timestamp ASC)
AND compaction = {
    'class': 'TimeWindowCompactionStrategy',
    'compaction_window_unit': 'DAYS',
    'compaction_window_size': '7'
};

// prediction result
CREATE TABLE IF NOT EXISTS rainfall_predictions (
    station_id text,
    year_week text,
    prediction_timestamp timestamp,
    model_name text,
    model_version text,
    prediction_horizon_hours int,
    predicted_rainfall_mm double,
    rain_probability double,
    confidence_score double,
    actual_rainfall_mm double,
    created_at timestamp,
    PRIMARY KEY (
        (station_id, year_week),
        prediction_timestamp,
        model_version
    )
)
WITH CLUSTERING ORDER BY (
    prediction_timestamp DESC,
    model_version ASC
);

// example query to retrieve a row of raw data
SELECT *
FROM rainfall_raw_data
WHERE station_id = 'BERLIN_1'
AND year_week = '2024-1';

// example query to retrieve a row of training data
SELECT *
FROM rainfall_attributes
WHERE station_id = 'BERLIN_1'
AND year_week = '2024-1';

// example query to retrive predicitons
SELECT *
FROM rainfall_predictions
WHERE station_id = 'BERLIN_1'
AND year_week = '2024-1';