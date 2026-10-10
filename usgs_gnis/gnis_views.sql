-- Run by do_usgs_gnis.sh after loading the source tables.
-- Set the psql variable DBSCHEMA to the schema containing those tables.

-- Non-unique indexes speed joins without asserting that source identifiers are
-- globally unique. The GNIS files have had identifier collisions and gaps.
CREATE INDEX IF NOT EXISTS idx_gnis_gaz_features_feature_id
    ON :"DBSCHEMA".gaz_features (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_domesticnames_feature_id
    ON :"DBSCHEMA".domesticnames (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_fdh_feature_id
    ON :"DBSCHEMA".featuredescriptionhistory (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_bgn_decisions_feature_id
    ON :"DBSCHEMA".gaz_bgndecisions (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_desigs_feature_id
    ON :"DBSCHEMA".gaz_desigs (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_incounties_feature_id
    ON :"DBSCHEMA".gaz_incounties (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_instates_feature_id
    ON :"DBSCHEMA".gaz_instates (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_names_feature_id
    ON :"DBSCHEMA".gaz_names (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_quads_feature_id
    ON :"DBSCHEMA".gaz_quads (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_quads_cell_id
    ON :"DBSCHEMA".gaz_quads (cell_id);
CREATE INDEX IF NOT EXISTS idx_gnis_cellgrid_cell_id
    ON :"DBSCHEMA".cellgrid_7_5minute (cell_id);
CREATE INDEX IF NOT EXISTS idx_gnis_federalcodes_feature_id
    ON :"DBSCHEMA".federalcodes (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_governmentunits_feature_id
    ON :"DBSCHEMA".governmentunits (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_historicalfeatures_feature_id
    ON :"DBSCHEMA".historicalfeatures (feature_id);
CREATE INDEX IF NOT EXISTS idx_gnis_populatedplaces_feature_id
    ON :"DBSCHEMA".populatedplaces (feature_id);

-- One row per feature from the spatial master layer, enriched with the
-- prepared domestic-name attributes and optional description/history text.
CREATE OR REPLACE VIEW :"DBSCHEMA".v_feature_detail AS
SELECT
    f.feature_id,
    f.geom,
    dn.feature_name,
    f.feature_class,
    dn.state_name,
    dn.state_numeric,
    dn.county_name,
    dn.county_numeric,
    dn.map_name,
    f.census_code,
    f.census_class_code,
    f.gsa_code,
    f.opm_code,
    f.date_created,
    f.date_edited,
    dn.bgn_type,
    dn.bgn_authority,
    dn.bgn_date,
    dn.bgn_type_desc,
    dn.bgn_authority_desc,
    dn.prim_lat_dms,
    dn.prim_long_dms,
    dn.prim_lat_dec,
    dn.prim_long_dec,
    dn.source_lat_dms,
    dn.source_long_dms,
    dn.source_lat_dec,
    dn.source_long_dec,
    f.unknowncoords,
    f.unknowncoords_desc,
    COALESCE(NULLIF(dh.description, ''), NULLIF(f.description, '')) AS description,
    COALESCE(NULLIF(dh.history, ''), NULLIF(f.history, '')) AS history
FROM :"DBSCHEMA".gaz_features AS f
LEFT JOIN :"DBSCHEMA".domesticnames AS dn
    ON dn.feature_id = f.feature_id
LEFT JOIN :"DBSCHEMA".featuredescriptionhistory AS dh
    ON dh.feature_id = f.feature_id;

-- Separate one-to-many views keep each name, designation, decision, county,
-- state, quadrangle, or federal-code record as its own row. LEFT JOINs retain
-- source rows whose feature_id has no match in Gaz_Features.
CREATE OR REPLACE VIEW :"DBSCHEMA".v_feature_names AS
SELECT
    n.feature_id,
    f.geom AS feature_geom,
    f.feature_class,
    n.feature_name,
    n.name_permanent_identifier,
    n.feature_name_official,
    n.feature_name_official_desc
FROM :"DBSCHEMA".gaz_names AS n
LEFT JOIN :"DBSCHEMA".gaz_features AS f
    ON f.feature_id = n.feature_id;

CREATE OR REPLACE VIEW :"DBSCHEMA".v_feature_designations AS
SELECT d.feature_id, f.geom AS feature_geom, f.feature_class, d.designation
FROM :"DBSCHEMA".gaz_desigs AS d
LEFT JOIN :"DBSCHEMA".gaz_features AS f
    ON f.feature_id = d.feature_id;

CREATE OR REPLACE VIEW :"DBSCHEMA".v_bgn_decisions AS
SELECT
    d.feature_id,
    f.geom AS feature_geom,
    f.feature_class,
    d.bgn_type,
    d.bgn_authority,
    d.bgn_date,
    d.bgn_type_desc,
    d.bgn_authority_desc
FROM :"DBSCHEMA".gaz_bgndecisions AS d
LEFT JOIN :"DBSCHEMA".gaz_features AS f
    ON f.feature_id = d.feature_id;

CREATE OR REPLACE VIEW :"DBSCHEMA".v_feature_counties AS
SELECT
    c.feature_id,
    f.geom AS feature_geom,
    f.feature_class,
    c.county_name,
    c.county_numeric,
    c.county_sequence
FROM :"DBSCHEMA".gaz_incounties AS c
LEFT JOIN :"DBSCHEMA".gaz_features AS f
    ON f.feature_id = c.feature_id;

CREATE OR REPLACE VIEW :"DBSCHEMA".v_feature_states AS
SELECT
    s.feature_id,
    f.geom AS feature_geom,
    f.feature_class,
    s.state_alpha,
    s.state_numeric,
    s.state_sequence
FROM :"DBSCHEMA".gaz_instates AS s
LEFT JOIN :"DBSCHEMA".gaz_features AS f
    ON f.feature_id = s.feature_id;

CREATE OR REPLACE VIEW :"DBSCHEMA".v_feature_quadrangles AS
SELECT
    q.feature_id,
    f.geom AS feature_geom,
    f.feature_class,
    q.cell_id,
    q.cell_sequence,
    g.map_name,
    g.geom AS cell_geom
FROM :"DBSCHEMA".gaz_quads AS q
LEFT JOIN :"DBSCHEMA".gaz_features AS f
    ON f.feature_id = q.feature_id
LEFT JOIN :"DBSCHEMA".cellgrid_7_5minute AS g
    ON g.cell_id = q.cell_id;

CREATE OR REPLACE VIEW :"DBSCHEMA".v_feature_federal_codes AS
SELECT
    fc.feature_id,
    f.geom AS feature_geom,
    f.feature_class,
    fc.feature_name,
    fc.census_code,
    fc.census_class_code,
    fc.gsa_code,
    fc.opm_code,
    fc.state_name,
    fc.state_numeric,
    fc.county_sequence,
    fc.county_name,
    fc.county_numeric
FROM :"DBSCHEMA".federalcodes AS fc
LEFT JOIN :"DBSCHEMA".gaz_features AS f
    ON f.feature_id = fc.feature_id;

-- Data-quality report: zero means no duplicate parent IDs or unmatched child
-- IDs for that relationship. These checks report issues without deleting data
-- or enforcing foreign keys.
SELECT check_name, issue_count
FROM (
    SELECT
        'duplicate Gaz_Features.feature_id groups'::text AS check_name,
        COUNT(*)::bigint AS issue_count
    FROM (
        SELECT feature_id
        FROM :"DBSCHEMA".gaz_features
        GROUP BY feature_id
        HAVING COUNT(*) > 1
    ) AS duplicate_ids

    UNION ALL
    SELECT 'Gaz_BGNDecisions -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".gaz_bgndecisions AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'Gaz_Desigs -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".gaz_desigs AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'Gaz_InCounties -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".gaz_incounties AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'Gaz_InStates -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".gaz_instates AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'Gaz_Names -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".gaz_names AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'Gaz_Quads.feature_id -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".gaz_quads AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'DomesticNames -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".domesticnames AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'FeatureDescriptionHistory -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".featuredescriptionhistory AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'FederalCodes -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".federalcodes AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'GovernmentUnits -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".governmentunits AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'HistoricalFeatures -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".historicalfeatures AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'PopulatedPlaces -> Gaz_Features unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".populatedplaces AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".gaz_features AS p
        WHERE p.feature_id = c.feature_id
    )

    UNION ALL
    SELECT 'Gaz_Quads.cell_id -> CellGrid_7_5Minute unmatched rows', COUNT(*)::bigint
    FROM :"DBSCHEMA".gaz_quads AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM :"DBSCHEMA".cellgrid_7_5minute AS g
        WHERE g.cell_id = c.cell_id
    )
) AS relationship_checks
ORDER BY check_name;
