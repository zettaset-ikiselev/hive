SELECT 'Upgrading MetaStore schema from 2.3.0 to 3.0.0' AS MESSAGE;

-- :r 026-HIVE-16556.mssql.sql
CREATE TABLE METASTORE_DB_PROPERTIES (
  PROPERTY_KEY VARCHAR(255) NOT NULL,
  PROPERTY_VALUE VARCHAR(1000) NOT NULL,
  DESCRIPTION VARCHAR(1000)
);

ALTER TABLE METASTORE_DB_PROPERTIES ADD CONSTRAINT PROPERTY_KEY_PK PRIMARY KEY (PROPERTY_KEY);

--:r 027-HIVE-16575.mssql.sql
CREATE INDEX CONSTRAINTS_CONSTRAINT_TYPE_INDEX ON KEY_CONSTRAINTS(CONSTRAINT_TYPE);

--:r 028-HIVE-16922.mssql.sql
UPDATE SERDE_PARAMS
SET PARAM_KEY='collection.delim'
WHERE PARAM_KEY='colelction.delim';

--:r 029-HIVE-16997.mssql.sql
ALTER TABLE PART_COL_STATS ADD BIT_VECTOR VARBINARY(MAX);
ALTER TABLE TAB_COL_STATS ADD BIT_VECTOR VARBINARY(MAX);

--:r 030-HIVE-16886.mssql.sql
INSERT INTO NOTIFICATION_SEQUENCE (NNI_ID, NEXT_EVENT_ID) SELECT 1,1 WHERE NOT EXISTS (SELECT NEXT_EVENT_ID FROM NOTIFICATION_SEQUENCE);

--:r 031-HIVE-17566.mssql.sql
CREATE TABLE WM_RESOURCEPLAN
(
    RP_ID bigint NOT NULL,
    "NAME" nvarchar(128) NOT NULL,
    QUERY_PARALLELISM int,
    STATUS nvarchar(20) NOT NULL
);

ALTER TABLE WM_RESOURCEPLAN ADD CONSTRAINT WM_RESOURCEPLAN_PK PRIMARY KEY (RP_ID);

CREATE UNIQUE INDEX UNIQUE_WM_RESOURCEPLAN ON WM_RESOURCEPLAN ("NAME");


CREATE TABLE WM_POOL
(
    POOL_ID bigint NOT NULL,
    RP_ID bigint NOT NULL,
    PATH nvarchar(1024) NOT NULL,
    PARENT_POOL_ID bigint,
    ALLOC_FRACTION float,
    QUERY_PARALLELISM int
);

ALTER TABLE WM_POOL ADD CONSTRAINT WM_POOL_PK PRIMARY KEY (POOL_ID);

CREATE UNIQUE INDEX UNIQUE_WM_POOL ON WM_POOL (RP_ID, PATH);
ALTER TABLE WM_POOL ADD CONSTRAINT WM_POOL_FK1 FOREIGN KEY (RP_ID) REFERENCES WM_RESOURCEPLAN (RP_ID);
ALTER TABLE WM_POOL ADD CONSTRAINT WM_POOL_FK2 FOREIGN KEY (PARENT_POOL_ID) REFERENCES WM_POOL (POOL_ID);


CREATE TABLE WM_TRIGGER
(
    TRIGGER_ID bigint NOT NULL,
    RP_ID bigint NOT NULL,
    "NAME" nvarchar(128) NOT NULL,
    TRIGGER_EXPRESSION nvarchar(1024),
    ACTION_EXPRESSION nvarchar(1024)
);

ALTER TABLE WM_TRIGGER ADD CONSTRAINT WM_TRIGGER_PK PRIMARY KEY (TRIGGER_ID);

CREATE UNIQUE INDEX UNIQUE_WM_TRIGGER ON WM_TRIGGER (RP_ID, "NAME");

ALTER TABLE WM_TRIGGER ADD CONSTRAINT WM_TRIGGER_FK1 FOREIGN KEY (RP_ID) REFERENCES WM_RESOURCEPLAN (RP_ID);


CREATE TABLE WM_POOL_TO_TRIGGER
(
    POOL_ID bigint NOT NULL,
    TRIGGER_ID bigint NOT NULL
);

ALTER TABLE WM_POOL_TO_TRIGGER ADD CONSTRAINT WM_POOL_TO_TRIGGER_PK PRIMARY KEY (POOL_ID, TRIGGER_ID);

ALTER TABLE WM_POOL_TO_TRIGGER ADD CONSTRAINT WM_POOL_TO_TRIGGER_FK1 FOREIGN KEY (POOL_ID) REFERENCES WM_POOL (POOL_ID);

ALTER TABLE WM_POOL_TO_TRIGGER ADD CONSTRAINT WM_POOL_TO_TRIGGER_FK2 FOREIGN KEY (TRIGGER_ID) REFERENCES WM_TRIGGER (TRIGGER_ID);


CREATE TABLE WM_MAPPING
(
    MAPPING_ID bigint NOT NULL,
    RP_ID bigint NOT NULL,
    ENTITY_TYPE nvarchar(10) NOT NULL,
    ENTITY_NAME nvarchar(128) NOT NULL,
    POOL_ID bigint NOT NULL,
    ORDERING int
);

ALTER TABLE WM_MAPPING ADD CONSTRAINT WM_MAPPING_PK PRIMARY KEY (MAPPING_ID);

CREATE UNIQUE INDEX UNIQUE_WM_MAPPING ON WM_MAPPING (RP_ID, ENTITY_TYPE, ENTITY_NAME);

ALTER TABLE WM_MAPPING ADD CONSTRAINT WM_MAPPING_FK1 FOREIGN KEY (RP_ID) REFERENCES WM_RESOURCEPLAN (RP_ID);

ALTER TABLE WM_MAPPING ADD CONSTRAINT WM_MAPPING_FK2 FOREIGN KEY (POOL_ID) REFERENCES WM_POOL (POOL_ID);

UPDATE VERSION SET SCHEMA_VERSION='3.0.0', VERSION_COMMENT='Hive release version 3.0.0' where VER_ID=1;
SELECT 'Finished upgrading MetaStore schema from 2.3.0 to 3.0.0' AS MESSAGE;