/*************************************************************************************************************
Script:             Configuración de Aplicación de Optimización de Red de Cadena de Suministro (SCNO)
Fecha de Creación:  2024-03-26
Autor:              B. Klein
Descripción:        Optimización de Red de Cadena de Suministro
Copyright © 2024 Snowflake Inc. Todos los derechos reservados
**************************************************************************************************************
RESUMEN DE CAMBIOS
Fecha(yyyy-mm-dd)   Autor                              Comentarios
------------------- -------------------                 --------------------------------------------
2024-03-26          B. Klein                            Creación Inicial
2025-09-20          J. Parrado                          Actualizado para usar ACCOUNTADMIN en todo el proceso
2025-09-20          J. Parrado                          Eliminado rol SCNO_ROLE - usando solo ACCOUNTADMIN
*************************************************************************************************************/

/* configurar roles */
use role accountadmin;
call system$wait(10);
create warehouse if not exists scno_wh WAREHOUSE_SIZE=SMALL comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';

/* NOTA: Eliminada la creación del rol SCNO_ROLE - usando solo ACCOUNTADMIN para todo el proceso */
/* ACCOUNTADMIN ya tiene todos los permisos necesarios, no se requiere rol adicional */

/* configurar objetos del lado del proveedor - usando ACCOUNTADMIN para evitar problemas de permisos */
use role accountadmin;
call system$wait(10);
use warehouse scno_wh;

/* crear base de datos */
create or replace database supply_chain_network_optimization_db comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
create or replace schema supply_chain_network_optimization_db.entities comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
create or replace schema supply_chain_network_optimization_db.relationships comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
create or replace schema supply_chain_network_optimization_db.results comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
create or replace schema supply_chain_network_optimization_db.code comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
create or replace schema supply_chain_network_optimization_db.streamlit comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
create or replace stage supply_chain_network_optimization_db.streamlit.streamlit_stage comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
drop schema if exists supply_chain_network_optimization_db.public;

/* tablas de entidades */
create or replace table supply_chain_network_optimization_db.entities.factory comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' (
	ID NUMBER(4,0),
	NAME VARCHAR(12),
	LATITUDE NUMBER(8,6),
	LONGITUDE NUMBER(9,6),
	LONG_LAT GEOGRAPHY,
	CITY VARCHAR(11),
	STATE VARCHAR(14),
	COUNTRY VARCHAR(13),
	PRODUCTION_CAPACITY NUMBER(5,0),
	PRODUCTION_COST NUMBER(9,5)
);

create or replace table supply_chain_network_optimization_db.entities.distributor comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' (
	ID NUMBER(4,0),
	NAME VARCHAR(16),
	LATITUDE NUMBER(8,6),
	LONGITUDE NUMBER(9,6),
	LONG_LAT GEOGRAPHY,
	CITY VARCHAR(13),
	STATE VARCHAR(14),
	COUNTRY VARCHAR(13),
	THROUGHPUT_CAPACITY NUMBER(4,0),
	THROUGHPUT_COST NUMBER(7,5)
);

create or replace table supply_chain_network_optimization_db.entities.customer comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' (
	ID NUMBER(38,0) NOT NULL,
	NAME VARCHAR(16777216) NOT NULL,
	LATITUDE VARCHAR(16777216) NOT NULL,
	LONGITUDE VARCHAR(16777216) NOT NULL,
	LONG_LAT VARCHAR(16777216) NOT NULL,
	DEMAND NUMBER(38,0) NOT NULL
);

/* tablas/vistas de relaciones */
create or replace table supply_chain_network_optimization_db.relationships.factory_to_distributor_rates comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' (
	FACTORY VARCHAR(12),
	DISTRIBUTOR VARCHAR(16),
	MILEAGE FLOAT,
	COST_FACTOR NUMBER(9,6),
	FREIGHT_COST FLOAT
);

create or replace view supply_chain_network_optimization_db.relationships.factory_to_distributor_rates_vw comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' as
select
        factory
    ,   distributor
    ,   freight_cost
from supply_chain_network_optimization_db.relationships.factory_to_distributor_rates
order by
        factory asc
    ,   distributor asc
;

create or replace view supply_chain_network_optimization_db.relationships.factory_to_distributor_mileage_vw comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' as
select
        factory
    ,   distributor
    ,   mileage
from supply_chain_network_optimization_db.relationships.factory_to_distributor_rates
order by
        factory asc
    ,   distributor asc
;

create or replace table supply_chain_network_optimization_db.relationships.distributor_to_customer_rates comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' (
	DISTRIBUTOR VARCHAR(16),
	CUSTOMER VARCHAR(16777216),
	MILEAGE FLOAT,
	COST_FACTOR NUMBER(9,6),
	FREIGHT_COST FLOAT
);

create or replace view supply_chain_network_optimization_db.relationships.distributor_to_customer_rates_vw comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' as
select
        distributor
    ,   customer
    ,   freight_cost
from supply_chain_network_optimization_db.relationships.distributor_to_customer_rates
order by
        distributor asc
    ,   customer asc
;

create or replace view supply_chain_network_optimization_db.relationships.distributor_to_customer_mileage_vw comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' as
select
        distributor
    ,   customer
    ,   mileage
from supply_chain_network_optimization_db.relationships.distributor_to_customer_rates
order by
        distributor asc
    ,   customer asc
;


/* tablas/vistas de resultados */
create or replace table supply_chain_network_optimization_db.results.model_results comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' (
    PROBLEM_NAME VARCHAR(16777216),
    RUN_DATE DATETIME,
    LP_STATUS VARCHAR(16777216),
    OBJECTIVE_VALUE FLOAT,
    DECISION_VARIABLES ARRAY,
    TOTAL_F2D_MILES FLOAT,
    TOTAL_D2C_MILES FLOAT,
    TOTAL_PRODUCTION_COSTS FLOAT,
    TOTAL_F2D_FREIGHT FLOAT,
    TOTAL_THROUGHPUT_COSTS FLOAT,
    TOTAL_D2C_FREIGHT FLOAT
);

create or replace view supply_chain_network_optimization_db.results.factory_to_distributor_shipments_vw comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' as
select distinct
        res.problem_name
    ,   res.run_date
    ,   '_' || split_part(replace(object_keys(val.value)[0],'"'),'__',2) || '_' as factory
    ,   split_part(replace(object_keys(val.value)[0],'"'),'__',3) as distributor
    ,   val.value[replace(object_keys(val.value)[0],'"')] as f2d_amount
from supply_chain_network_optimization_db.results.model_results res
, lateral flatten( input => decision_variables ) val
where split_part(replace(object_keys(val.value)[0],'"'),'__',1) = 'F2DRoute'
;

create or replace view supply_chain_network_optimization_db.results.distributor_to_customer_shipments_vw comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' as
select distinct
        res.problem_name
    ,   res.run_date
    ,   '_' || split_part(replace(object_keys(val.value)[0],'"'),'__',2) || '_' as distributor
    ,   '_' || split_part(replace(object_keys(val.value)[0],'"'),'__',3) || '_' as customer
    ,   val.value[replace(object_keys(val.value)[0],'"')] as d2c_amount
from supply_chain_network_optimization_db.results.model_results res
, lateral flatten( input => decision_variables ) val
where split_part(replace(object_keys(val.value)[0],'"'),'__',1) = 'D2CRoute'
;

create or replace view supply_chain_network_optimization_db.results.factory_to_distributor_shipment_details_vw comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' as
select distinct
        ship.problem_name
    ,   ship.run_date
    ,   ship.f2d_amount as factory_to_distributor_shipped_amount
    ,   to_geography(fact.long_lat) as factory_geocodes
    ,   st_asgeojson(to_geography(fact.long_lat)):coordinates[0] as factory_longitude
    ,   st_asgeojson(to_geography(fact.long_lat)):coordinates[1] as factory_latitude
    ,   fact.name as factory_name
    ,   fact.city as factory_city
    ,   fact.state as factory_state
    ,   fact.country as factory_country
    ,   to_geography(dist.long_lat) as distributor_geocodes
    ,   st_asgeojson(to_geography(dist.long_lat)):coordinates[0] as distributor_longitude
    ,   st_asgeojson(to_geography(dist.long_lat)):coordinates[1] as distributor_latitude
    ,   dist.name as distributor_name
    ,   dist.city as distributor_city
    ,   dist.state as distributor_state
    ,   dist.country as distributor_country
    ,   f2dr.mileage as mileage
    ,   f2dr.freight_cost as freight_cost
from supply_chain_network_optimization_db.results.factory_to_distributor_shipments_vw ship
inner join supply_chain_network_optimization_db.entities.factory fact on ship.factory = replace(fact.name,' ','_')
inner join supply_chain_network_optimization_db.entities.distributor dist on ship.distributor = replace(dist.name,' ','_')
inner join supply_chain_network_optimization_db.relationships.factory_to_distributor_rates f2dr on
    f2dr.factory = fact.name and
    f2dr.distributor = dist.name
;

create or replace view supply_chain_network_optimization_db.results.distributor_to_customer_shipment_details_vw comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' as
select distinct
        ship.problem_name
    ,   ship.run_date
    ,   ship.d2c_amount as distributor_to_customer_shipped_amount
    ,   to_geography(dist.long_lat) as distributor_geocodes
    ,   st_asgeojson(to_geography(dist.long_lat)):coordinates[0] as distributor_longitude
    ,   st_asgeojson(to_geography(dist.long_lat)):coordinates[1] as distributor_latitude
    ,   dist.name as distributor_name
    ,   dist.city as distributor_city
    ,   dist.state as distributor_state
    ,   dist.country as distributor_country
    ,   to_geography(cust.long_lat) as customer_geocodes
    ,   st_asgeojson(to_geography(cust.long_lat)):coordinates[0] as customer_longitude
    ,   st_asgeojson(to_geography(cust.long_lat)):coordinates[1] as customer_latitude
    ,   cust.name as customer_name
    ,   d2cr.mileage as mileage
    ,   d2cr.freight_cost as freight_cost
from supply_chain_network_optimization_db.results.distributor_to_customer_shipments_vw ship
inner join supply_chain_network_optimization_db.entities.distributor dist on ship.distributor = replace(dist.name,' ','_')
inner join supply_chain_network_optimization_db.entities.customer cust on rtrim(ltrim(customer,'_'),'_') = replace(cust.name,' ','_')
inner join supply_chain_network_optimization_db.relationships.distributor_to_customer_rates d2cr on
    d2cr.distributor = dist.name and
    d2cr.customer = cust.name
;

/* objetos de despliegue de streamlit */

/* procedimiento almacenado auxiliar para ayudar a crear los objetos */
create or replace procedure supply_chain_network_optimization_db.code.put_to_stage(stage varchar,filename varchar, content varchar)
returns string
language python
runtime_version=3.10
packages=('snowflake-snowpark-python')
handler='put_to_stage'
comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}'
AS $$
import io
import os

def put_to_stage(session, stage, filename, content):
    local_path = '/tmp'
    local_file = os.path.join(local_path, filename)
    f = open(local_file, "w", encoding='utf-8')
    f.write(content)
    f.close()
    session.file.put(local_file, '@'+stage, auto_compress=False, overwrite=True)
    return "archivo guardado "+filename+" en stage "+stage
$$;

create or replace table supply_chain_network_optimization_db.code.script comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' (
	name varchar,
	script varchar(16777216)
);

/* streamlit */
insert into supply_chain_network_optimization_db.code.script (name , script)
values ('STREAMLIT_V1',$$

from snowflake.snowpark.context import get_active_session
import streamlit as st
from abc import ABC, abstractmethod
import datetime
from snowflake.snowpark.functions import col
import operator
import pandas as pd
from faker import Faker
from random import randint
from pulp import *
from snowflake.cortex import Complete,ExtractAnswer
import json


# Verificar tipo de conexión de snowflake
def set_session():
    try:
        import snowflake.permissions as permissions

        session = get_active_session()

        # fallará para una aplicación no nativa
        privilege_check = permissions.get_held_account_privileges(["EXECUTE TASK"])

        st.session_state["streamlit_mode"] = "NativeApp"
    except:
        try:
            session = get_active_session()

            st.session_state["streamlit_mode"] = "SiS"
        except:
            import snowflake_conn as sfc

            session = sfc.init_snowpark_session("account_1")

            st.session_state["streamlit_mode"] = "OSS"

    return session


# Iniciar sesión
session = set_session()

fake = Faker()

# datos de demostración
factories_sql = '''insert overwrite into supply_chain_network_optimization_db.entities.factory
    select
            1000 as id
        ,   '_Factory_1_' as name
        ,   39.798363 as latitude
        ,   -89.654961 as longitude
        ,   to_geography('POINT (-89.654961 39.798363)') as long_lat
        ,   'Springfield' as city
        ,   'Illinois' as state
        ,   'United States' as country
        ,   7000 as production_capacity
        ,   600 as production_cost
union
    select
            1005 as id
        ,   '_Factory_2_' as name
        ,   38.576668 as latitude
        ,   -121.493629 as longitude
        ,   to_geography('POINT (-121.493629 38.576668)') as long_lat
        ,   'Sacramento' as city
        ,   'California' as state
        ,   'United States' as country
        ,   11000 as production_capacity
        ,   1100 as production_cost
union
    select
            1010 as id
        ,   '_Factory_3_' as name
        ,   39.739227 as latitude
        ,   -104.984856 as longitude
        ,   to_geography('POINT (-104.984856 39.739227)') as long_la
        ,   'Denver' as city
        ,   'Colorado' as state
        ,   'United States' as country
        ,   8500 as production_capacity
        ,   750.5 as production_cost
union
    select
            1015 as id
        ,   '_Factory_4_' as name
        ,   30.438118 as latitude
        ,   -84.281296 as longitude
        ,   to_geography('POINT (-84.281296 30.438118)') as long_lat
        ,   'Tallahassee' as city
        ,   'Florida' as state
        ,   'United States' as country
        ,   7500 as production_capacity
        ,   760 as production_cost
union
    select
            1020 as id
        ,   '_Factory_5_' as name
        ,   43.617775 as latitude
        ,   -116.199722 as longitude
        ,   to_geography('POINT (-116.199722 43.617775)') as long_lat
        ,   'Boise' as city
        ,   'Idaho' as state
        ,   'United States' as country
        ,   11000 as production_capacity
        ,   690 as production_cost
union
    select
            1025 as id
        ,   '_Factory_6_' as name
        ,   44.307167 as latitude
        ,   -69.781693 as longitude
        ,   to_geography('POINT (-69.781693 44.307167)') as long_lat
        ,   'Augusta' as city
        ,   'Maine' as state
        ,   'United States' as country
        ,   4100 as production_capacity
        ,   680 as production_cost
union
    select
            1030 as id
        ,   '_Factory_7_' as name
        ,   46.585709 as latitude
        ,   -112.018417 as longitude
        ,   to_geography('POINT (-112.018417 46.585709)') as long_lat
        ,   'Helena' as city
        ,   'Montana' as state
        ,   'United States' as country
        ,   6600 as production_capacity
        ,   800 as production_cost
union
    select
            1035 as id
        ,   '_Factory_8_' as name
        ,   42.652843 as latitude
        ,   -73.757874 as longitude
        ,   to_geography('POINT (-73.757874 42.652843)') as long_lat
        ,   'Albany' as city
        ,   'New York' as state
        ,   'United States' as country
        ,   6000 as production_capacity
        ,   1200 as production_cost
union
    select
            1050 as id
        ,   '_Factory_9_' as name
        ,   30.27467 as latitude
        ,   -97.740349 as longitude
        ,   to_geography('POINT (-97.740349 30.27467)') as long_lat
        ,   'Austin' as city
        ,   'Texas' as state
        ,   'United States' as country
        ,   5200 as production_capacity
        ,   750 as production_cost
        union
    select
            1045 as id
        ,   '_Factory_10_' as name
        ,   34.000343 as latitude
        ,   -81.033211 as longitude
        ,   to_geography('POINT (-81.033211 34.000343)') as long_lat
        ,   'Columbia' as city
        ,   'South Carolina' as state
        ,   'United States' as country
        ,   4500 as production_capacity
        ,   500 as production_cost
;'''

$$);

/* agregar archivo de entorno para streamlit - incluye todas las referencias a bibliotecas que el Streamlit necesita */
insert into supply_chain_network_optimization_db.code.script (name , script)
values ( 'ENVIRONMENT_V1',$$
name: sf_env
channels:
- snowflake
dependencies:
- pulp
- faker
- snowflake-ml-python

$$);

/* poner archivos en stage */
call supply_chain_network_optimization_db.code.put_to_stage('supply_chain_network_optimization_db.streamlit.streamlit_stage','streamlit_ui.py', (select script from supply_chain_network_optimization_db.code.script where name = 'STREAMLIT_V1'));
call supply_chain_network_optimization_db.code.put_to_stage('supply_chain_network_optimization_db.streamlit.streamlit_stage','environment.yml', (select script from supply_chain_network_optimization_db.code.script where name = 'ENVIRONMENT_V1'));

/* crear streamlit */
create or replace streamlit supply_chain_network_optimization_db.streamlit.supply_chain_network_optimization
  root_location = '@supply_chain_network_optimization_db.streamlit.streamlit_stage'
  main_file = '/streamlit_ui.py'
  query_warehouse = scno_wh
  comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
