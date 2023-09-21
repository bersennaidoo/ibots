#!/bin/bash
set -e

psql -v -U postgres -h localhost -d postgres<<-EOSQL
  CREATE DATABASE mallbots;

  CREATE USER mallbots_user WITH ENCRYPTED PASSWORD 'mallbots_pass';

  GRANT CONNECT ON DATABASE mallbots TO mallbots_user;
EOSQL

psql -v --username postgres -h localhost --dbname "mallbots"<<-EOSQL
  -- Apply to keep modifications to the created_at column from being made
  CREATE OR REPLACE FUNCTION created_at_trigger()
  RETURNS TRIGGER AS \$\$
  BEGIN
    NEW.created_at := OLD.created_at;
    RETURN NEW;
  END;
  \$\$ language 'plpgsql';

  -- Apply to a table to automatically update update_at columns
  CREATE OR REPLACE FUNCTION updated_at_trigger()
  RETURNS TRIGGER AS \$\$
  BEGIN
     IF row(NEW.*) IS DISTINCT FROM row(OLD.*) THEN
        NEW.updated_at = NOW();
        RETURN NEW;
     ELSE
        RETURN OLD;
     END IF;
  END;
  \$\$ language 'plpgsql';
EOSQL
