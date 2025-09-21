/*************************************************************************************************************
Script:             Configuración de la Aplicación de Optimización de Red de Cadena de Suministro (SCNO)
Create Date:        2024-03-26
Author:             B. Klein
Description:        Optimización de Red de Cadena de Suministro
Copyright © 2024 Snowflake Inc. Todos los derechos reservados
**************************************************************************************************************
RESUMEN DE CAMBIOS
Date(yyyy-mm-dd)    Author                              Comments
------------------- -------------------                 --------------------------------------------
2024-03-26          B. Klein                            Creación Inicial
*************************************************************************************************************/

/* configurar roles */
use role accountadmin;
call system$wait(10);
create warehouse if not exists scno_wh WAREHOUSE_SIZE=SMALL comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';

/* crear rol y agregar permisos requeridos por el rol para la instalación del framework */
create role if not exists scno_role;

/* realizar concesiones de permisos */
grant create share on account to role scno_role;
grant import share on account to role scno_role;
grant create database on account to role scno_role with grant option;
grant execute task on account to role scno_role;
grant create application package on account to role scno_role;
grant create application on account to role scno_role;
grant create data exchange listing on account to role scno_role;
/* agregar rol de base de datos cortex_user para usar Cortex */
grant database role snowflake.cortex_user to role scno_role;
grant role scno_role to role sysadmin;
grant usage, operate on warehouse scno_wh to role scno_role;

/* configurar objetos del lado del proveedor */
use role scno_role;
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
	NAME VARCHAR(20),
	LATITUDE NUMBER(8,6),
	LONGITUDE NUMBER(9,6),
	LONG_LAT GEOGRAPHY,
	CITY VARCHAR(20),
	STATE VARCHAR(25),
	COUNTRY VARCHAR(15),
	PRODUCTION_CAPACITY NUMBER(5,0),
	PRODUCTION_COST NUMBER(9,5)
);

create or replace table supply_chain_network_optimization_db.entities.distributor comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}' (
	ID NUMBER(4,0),
	NAME VARCHAR(25),
	LATITUDE NUMBER(8,6),
	LONGITUDE NUMBER(9,6),
	LONG_LAT GEOGRAPHY,
	CITY VARCHAR(20),
	STATE VARCHAR(25),
	COUNTRY VARCHAR(15),
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
	FACTORY VARCHAR(20),
	DISTRIBUTOR VARCHAR(25),
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
	DISTRIBUTOR VARCHAR(25),
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
    return "saved file "+filename+" in stage "+stage
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


# Check snowflake connection type
def set_session():
    try:
        import snowflake.permissions as permissions

        session = get_active_session()

        # will fail for a non native app
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


# Initiate session
session = set_session()

fake = Faker()

# demo data
factories_sql = '''insert overwrite into supply_chain_network_optimization_db.entities.factory
    select
            1000 as id
        ,   '_Factory_1_' as name
        ,   4.7110 as latitude
        ,   -74.0721 as longitude
        ,   to_geography('POINT (-74.0721 4.7110)') as long_lat
        ,   'Bogotá' as city
        ,   'Cundinamarca' as state
        ,   'Colombia' as country
        ,   12000 as production_capacity
        ,   850 as production_cost
union
    select
            1005 as id
        ,   '_Factory_2_' as name
        ,   6.2442 as latitude
        ,   -75.5812 as longitude
        ,   to_geography('POINT (-75.5812 6.2442)') as long_lat
        ,   'Medellín' as city
        ,   'Antioquia' as state
        ,   'Colombia' as country
        ,   10000 as production_capacity
        ,   780 as production_cost
union
    select
            1010 as id
        ,   '_Factory_3_' as name
        ,   3.4516 as latitude
        ,   -76.5320 as longitude
        ,   to_geography('POINT (-76.5320 3.4516)') as long_lat
        ,   'Cali' as city
        ,   'Valle del Cauca' as state
        ,   'Colombia' as country
        ,   9500 as production_capacity
        ,   720 as production_cost
union
    select
            1015 as id
        ,   '_Factory_4_' as name
        ,   10.9685 as latitude
        ,   -74.7813 as longitude
        ,   to_geography('POINT (-74.7813 10.9685)') as long_lat
        ,   'Barranquilla' as city
        ,   'Atlántico' as state
        ,   'Colombia' as country
        ,   8000 as production_capacity
        ,   690 as production_cost
union
    select
            1020 as id
        ,   '_Factory_5_' as name
        ,   10.3910 as latitude
        ,   -75.4794 as longitude
        ,   to_geography('POINT (-75.4794 10.3910)') as long_lat
        ,   'Cartagena' as city
        ,   'Bolívar' as state
        ,   'Colombia' as country
        ,   7500 as production_capacity
        ,   710 as production_cost
union
    select
            1025 as id
        ,   '_Factory_6_' as name
        ,   7.1193 as latitude
        ,   -73.1227 as longitude
        ,   to_geography('POINT (-73.1227 7.1193)') as long_lat
        ,   'Bucaramanga' as city
        ,   'Santander' as state
        ,   'Colombia' as country
        ,   6500 as production_capacity
        ,   680 as production_cost
union
    select
            1030 as id
        ,   '_Factory_7_' as name
        ,   4.8087 as latitude
        ,   -75.6906 as longitude
        ,   to_geography('POINT (-75.6906 4.8087)') as long_lat
        ,   'Pereira' as city
        ,   'Risaralda' as state
        ,   'Colombia' as country
        ,   5500 as production_capacity
        ,   650 as production_cost
union
    select
            1035 as id
        ,   '_Factory_8_' as name
        ,   5.0689 as latitude
        ,   -75.5174 as longitude
        ,   to_geography('POINT (-75.5174 5.0689)') as long_lat
        ,   'Manizales' as city
        ,   'Caldas' as state
        ,   'Colombia' as country
        ,   5000 as production_capacity
        ,   630 as production_cost
union
    select
            1050 as id
        ,   '_Factory_9_' as name
        ,   4.4389 as latitude
        ,   -75.2322 as longitude
        ,   to_geography('POINT (-75.2322 4.4389)') as long_lat
        ,   'Ibagué' as city
        ,   'Tolima' as state
        ,   'Colombia' as country
        ,   4500 as production_capacity
        ,   600 as production_cost
        union
    select
            1045 as id
        ,   '_Factory_10_' as name
        ,   4.1420 as latitude
        ,   -73.6266 as longitude
        ,   to_geography('POINT (-73.6266 4.1420)') as long_lat
        ,   'Villavicencio' as city
        ,   'Meta' as state
        ,   'Colombia' as country
        ,   4000 as production_capacity
        ,   580 as production_cost
;'''
distributor_sql = '''insert overwrite into supply_chain_network_optimization_db.entities.distributor
    select
            2000 as id
        ,   '_Distributor_1_' as name
        ,   4.7110 as latitude
        ,   -74.0721 as longitude
        ,   to_geography('POINT (-74.0721 4.7110)') as long_lat
        ,   'Bogotá' as city
        ,   'Cundinamarca' as state
        ,   'Colombia' as country
        ,   3500 as throughput_capacity
        ,   12 as throughput_cost
union
    select
            2002 as id
        ,   '_Distributor_2_' as name
        ,   6.2442 as latitude
        ,   -75.5812 as longitude
        ,   to_geography('POINT (-75.5812 6.2442)') as long_lat
        ,   'Medellín' as city
        ,   'Antioquia' as state
        ,   'Colombia' as country
        ,   2800 as throughput_capacity
        ,   10 as throughput_cost
union
    select
            2004 as id
        ,   '_Distributor_3_' as name
        ,   3.4516 as latitude
        ,   -76.5320 as longitude
        ,   to_geography('POINT (-76.5320 3.4516)') as long_lat
        ,   'Cali' as city
        ,   'Valle del Cauca' as state
        ,   'Colombia' as country
        ,   2600 as throughput_capacity
        ,   9 as throughput_cost
union
    select
            2006 as id
        ,   '_Distributor_4_' as name
        ,   10.9685 as latitude
        ,   -74.7813 as longitude
        ,   to_geography('POINT (-74.7813 10.9685)') as long_lat
        ,   'Barranquilla' as city
        ,   'Atlántico' as state
        ,   'Colombia' as country
        ,   2200 as throughput_capacity
        ,   8 as throughput_cost
union
    select
            2008 as id
        ,   '_Distributor_5_' as name
        ,   10.3910 as latitude
        ,   -75.4794 as longitude
        ,   to_geography('POINT (-75.4794 10.3910)') as long_lat
        ,   'Cartagena' as city
        ,   'Bolívar' as state
        ,   'Colombia' as country
        ,   2000 as throughput_capacity
        ,   8 as throughput_cost
union
    select
            2010 as id
        ,   '_Distributor_6_' as name
        ,   7.1193 as latitude
        ,   -73.1227 as longitude
        ,   to_geography('POINT (-73.1227 7.1193)') as long_lat
        ,   'Bucaramanga' as city
        ,   'Santander' as state
        ,   'Colombia' as country
        ,   1800 as throughput_capacity
        ,   7 as throughput_cost
union
    select
            2012 as id
        ,   '_Distributor_7_' as name
        ,   4.8087 as latitude
        ,   -75.6906 as longitude
        ,   to_geography('POINT (-75.6906 4.8087)') as long_lat
        ,   'Pereira' as city
        ,   'Risaralda' as state
        ,   'Colombia' as country
        ,   1500 as throughput_capacity
        ,   6 as throughput_cost
union
    select
            2014 as id
        ,   '_Distributor_8_' as name
        ,   5.0689 as latitude
        ,   -75.5174 as longitude
        ,   to_geography('POINT (-75.5174 5.0689)') as long_lat
        ,   'Manizales' as city
        ,   'Caldas' as state
        ,   'Colombia' as country
        ,   1400 as throughput_capacity
        ,   6 as throughput_cost
union
    select
            2016 as id
        ,   '_Distributor_9_' as name
        ,   4.4389 as latitude
        ,   -75.2322 as longitude
        ,   to_geography('POINT (-75.2322 4.4389)') as long_lat
        ,   'Ibagué' as city
        ,   'Tolima' as state
        ,   'Colombia' as country
        ,   1300 as throughput_capacity
        ,   5 as throughput_cost
union
    select
            2018 as id
        ,   '_Distributor_10_' as name
        ,   4.1420 as latitude
        ,   -73.6266 as longitude
        ,   to_geography('POINT (-73.6266 4.1420)') as long_lat
        ,   'Villavicencio' as city
        ,   'Meta' as state
        ,   'Colombia' as country
        ,   1200 as throughput_capacity
        ,   5 as throughput_cost
union
    select
            2020 as id
        ,   '_Distributor_11_' as name
        ,   11.2408 as latitude
        ,   -74.1990 as longitude
        ,   to_geography('POINT (-74.1990 11.2408)') as long_lat
        ,   'Santa Marta' as city
        ,   'Magdalena' as state
        ,   'Colombia' as country
        ,   1100 as throughput_capacity
        ,   7 as throughput_cost
union
    select
            2022 as id
        ,   '_Distributor_12_' as name
        ,   8.7500 as latitude
        ,   -75.8814 as longitude
        ,   to_geography('POINT (-75.8814 8.7500)') as long_lat
        ,   'Montería' as city
        ,   'Córdoba' as state
        ,   'Colombia' as country
        ,   1000 as throughput_capacity
        ,   6 as throughput_cost
union
    select
            2024 as id
        ,   '_Distributor_13_' as name
        ,   9.3077 as latitude
        ,   -75.3975 as longitude
        ,   to_geography('POINT (-75.3975 9.3077)') as long_lat
        ,   'Sincelejo' as city
        ,   'Sucre' as state
        ,   'Colombia' as country
        ,   800 as throughput_capacity
        ,   5 as throughput_cost
union
    select
            2026 as id
        ,   '_Distributor_14_' as name
        ,   8.3114 as latitude
        ,   -73.3475 as longitude
        ,   to_geography('POINT (-73.3475 8.3114)') as long_lat
        ,   'Valledupar' as city
        ,   'Cesar' as state
        ,   'Colombia' as country
        ,   900 as throughput_capacity
        ,   6 as throughput_cost
union
    select
            2028 as id
        ,   '_Distributor_15_' as name
        ,   2.9273 as latitude
        ,   -75.2819 as longitude
        ,   to_geography('POINT (-75.2819 2.9273)') as long_lat
        ,   'Neiva' as city
        ,   'Huila' as state
        ,   'Colombia' as country
        ,   1100 as throughput_capacity
        ,   5 as throughput_cost
union
    select
            2030 as id
        ,   '_Distributor_16_' as name
        ,   2.4448 as latitude
        ,   -76.6147 as longitude
        ,   to_geography('POINT (-76.6147 2.4448)') as long_lat
        ,   'Popayán' as city
        ,   'Cauca' as state
        ,   'Colombia' as country
        ,   800 as throughput_capacity
        ,   5 as throughput_cost
union
    select
            2032 as id
        ,   '_Distributor_17_' as name
        ,   1.2136 as latitude
        ,   -77.2811 as longitude
        ,   to_geography('POINT (-77.2811 1.2136)') as long_lat
        ,   'Pasto' as city
        ,   'Nariño' as state
        ,   'Colombia' as country
        ,   900 as throughput_capacity
        ,   6 as throughput_cost
union
    select
            2034 as id
        ,   '_Distributor_18_' as name
        ,   5.3350 as latitude
        ,   -72.3958 as longitude
        ,   to_geography('POINT (-72.3958 5.3350)') as long_lat
        ,   'Tunja' as city
        ,   'Boyacá' as state
        ,   'Colombia' as country
        ,   700 as throughput_capacity
        ,   4 as throughput_cost
union
    select
            2036 as id
        ,   '_Distributor_19_' as name
        ,   6.2518 as latitude
        ,   -67.5069 as longitude
        ,   to_geography('POINT (-67.5069 6.2518)') as long_lat
        ,   'Puerto Carreño' as city
        ,   'Vichada' as state
        ,   'Colombia' as country
        ,   400 as throughput_capacity
        ,   3 as throughput_cost
union
    select
            2038 as id
        ,   '_Distributor_20_' as name
        ,   5.3350 as latitude
        ,   -72.3958 as longitude
        ,   to_geography('POINT (-72.3958 5.3350)') as long_lat
        ,   'Yopal' as city
        ,   'Casanare' as state
        ,   'Colombia' as country
        ,   600 as throughput_capacity
        ,   4 as throughput_cost
union
    select
            2040 as id
        ,   '_Distributor_21_' as name
        ,   7.0669 as latitude
        ,   -70.7616 as longitude
        ,   to_geography('POINT (-70.7616 7.0669)') as long_lat
        ,   'Arauca' as city
        ,   'Arauca' as state
        ,   'Colombia' as country
        ,   500 as throughput_capacity
        ,   3 as throughput_cost
union
    select
            2042 as id
        ,   '_Distributor_22_' as name
        ,   1.6144 as latitude
        ,   -75.6062 as longitude
        ,   to_geography('POINT (-75.6062 1.6144)') as long_lat
        ,   'Florencia' as city
        ,   'Caquetá' as state
        ,   'Colombia' as country
        ,   600 as throughput_capacity
        ,   4 as throughput_cost
union
    select
            2044 as id
        ,   '_Distributor_23_' as name
        ,   0.8333 as latitude
        ,   -76.2500 as longitude
        ,   to_geography('POINT (-76.2500 0.8333)') as long_lat
        ,   'Mocoa' as city
        ,   'Putumayo' as state
        ,   'Colombia' as country
        ,   400 as throughput_capacity
        ,   3 as throughput_cost
union
    select
            2046 as id
        ,   '_Distributor_24_' as name
        ,   -4.2158 as latitude
        ,   -69.9406 as longitude
        ,   to_geography('POINT (-69.9406 -4.2158)') as long_lat
        ,   'Leticia' as city
        ,   'Amazonas' as state
        ,   'Colombia' as country
        ,   300 as throughput_capacity
        ,   2 as throughput_cost
union
    select
            2048 as id
        ,   '_Distributor_25_' as name
        ,   5.6910 as latitude
        ,   -76.6608 as longitude
        ,   to_geography('POINT (-76.6608 5.6910)') as long_lat
        ,   'Quibdó' as city
        ,   'Chocó' as state
        ,   'Colombia' as country
        ,   500 as throughput_capacity
        ,   4 as throughput_cost
;'''
fact_to_dist_sql = '''insert overwrite into supply_chain_network_optimization_db.relationships.factory_to_distributor_rates
with mileage as
    ((st_distance(fact.long_lat, dist.long_lat))/1609.344),
cost_factor as
    ((uniform(1, 20, random())+89)/100)
select
        fact.name as factory
    ,   dist.name as distributor
    ,   mileage as mileage
    ,   cost_factor as cost_factor
    ,   mileage*cost_factor as freight_cost
from supply_chain_network_optimization_db.entities.factory fact
cross join supply_chain_network_optimization_db.entities.distributor dist
order by
        fact.name asc
    ,   dist.name asc
;'''
dist_to_cust_sql = '''insert overwrite into supply_chain_network_optimization_db.relationships.distributor_to_customer_rates
with mileage as
    ((st_distance(dist.long_lat, to_geography(cust.long_lat)))/1609.344),
cost_factor as
    ((uniform(1, 20, random())+89)/100)
select
        dist.name as distributor
    ,   cust.name as customer
    ,   mileage as mileage
    ,   cost_factor as cost_factor
    ,   mileage*cost_factor as freight_cost
from supply_chain_network_optimization_db.entities.distributor dist
cross join supply_chain_network_optimization_db.entities.customer cust
order by
        dist.name asc
    ,   cust.name asc
;'''

# needed after any factory changes due to pivot
fact_to_dist_rate_matrix_sql = """select 'create or replace table
supply_chain_network_optimization_db.relationships.factory_to_distributor_rates_matrix as select * from
supply_chain_network_optimization_db.relationships.factory_to_distributor_rates_vw pivot (avg(freight_cost) for factory in (
'||listagg (distinct ''''||factory||'''', ',') ||')) order by distributor;' as query from
supply_chain_network_optimization_db.relationships.factory_to_distributor_rates_vw;"""
fact_to_dist_mileage_matrix_sql = """select 'create or replace table
supply_chain_network_optimization_db.relationships.factory_to_distributor_mileage_matrix as select * from
supply_chain_network_optimization_db.relationships.factory_to_distributor_mileage_vw pivot (avg(mileage) for factory in (
'||listagg (distinct ''''||factory||'''', ',') ||')) order by distributor;' as query from
supply_chain_network_optimization_db.relationships.factory_to_distributor_mileage_vw;"""

# needed after any distributor changes due to pivot
dist_to_cust_rate_matrix_sql = """select 'create or replace table
supply_chain_network_optimization_db.relationships.distributor_to_customer_rates_matrix as select * from
supply_chain_network_optimization_db.relationships.distributor_to_customer_rates_vw pivot (avg(freight_cost) for distributor in (
'||listagg (distinct ''''||distributor||'''', ',') ||')) order by customer;' as query from
supply_chain_network_optimization_db.relationships.distributor_to_customer_rates_vw;"""
dist_to_cust_mileage_matrix_sql = """select 'create or replace table
supply_chain_network_optimization_db.relationships.distributor_to_customer_mileage_matrix as select * from
supply_chain_network_optimization_db.relationships.distributor_to_customer_mileage_vw pivot (avg(mileage) for distributor in (
'||listagg (distinct ''''||distributor||'''', ',') ||')) order by customer;' as query from
supply_chain_network_optimization_db.relationships.distributor_to_customer_mileage_vw;"""

# Configuración de página
st.set_page_config(
    page_title="Optimización de Red de Cadena de Suministro",
    page_icon="❄️️",
    layout="wide",
    initial_sidebar_state="expanded",
    menu_items={
        'Get Help': 'https://github.com/snowflakecorp/supply-chain-optimization',
        'Report a bug': "https://github.com/snowflakecorp/supply-chain-optimization",
        'About': "Esta aplicación realiza un modelo de optimización de red para una cadena de suministro de 3 niveles"
    }
)

# Establecer página inicial
if "page" not in st.session_state:
    st.session_state.page = "Bienvenida"


# Establece la página basada en el nombre de página
def set_page(page: str):
    st.session_state.page = page


class OptimizationModel:
    """
    Una clase utilizada para representar un modelo de optimización de red de cadena de suministro. Un modelo de 
    optimización maximiza/minimiza matemáticamente una función objetivo basada en variables de decisión y un 
    conjunto dado de restricciones.

    Para usar:
        - Instanciar la clase
        - Ejecutar el método prepare_data para configurar los datos del modelo
        - Ejecutar el método solve, pasando uno de los nombres de problema soportados
        - Hay un método solve_sample para ejecutar un modelo independiente

    Cualquier modelo es específico para las entidades, relaciones, restricciones y objetivo de un negocio particular.
    Este es un modelo demo que describe un escenario típico de cadena de suministro.
    """

    def __init__(self):
        self.factories = []
        self.production_capacities = {}
        self.production_costs = {}
        self.distributors = []
        self.throughput_capacities = {}
        self.throughput_costs = {}
        self.customers = []
        self.demand = {}
        self.factory_to_distributor_rates = {}
        self.distributor_to_customer_rates = {}
        self.factory_to_distributor_mileage = {}
        self.distributor_to_customer_mileage = {}
        self.problem_name = None
        self.lp_status = None
        self.decision_variables = None
        self.objective_value = None
        self.total_f2d_miles = None
        self.total_d2c_miles = None
        self.total_production_costs = None
        self.total_f2d_freight = None
        self.total_throughput_costs = None
        self.total_d2c_freight = None

    def solve_sample(self):
        """
        El Problema de Distribución de Cerveza con Extensión para un Nodo de Suministro Competidor para el Modelador PuLP
        """

        # Crea una lista de todos los nodos de suministro
        warehouses = ["A", "B", "C"]

        # Crea un diccionario para el número de unidades de suministro para cada nodo de suministro
        supply = {"A": 1000, "B": 4000, "C": 100}

        # Crea una lista de todos los nodos de demanda
        bars = ["1", "2", "3", "4", "5"]

        # Crea un diccionario para el número de unidades de demanda para cada nodo de demanda
        demand = {
            "1": 500,
            "2": 900,
            "3": 1800,
            "4": 200,
            "5": 700,
        }

        # Crea una lista de costos de cada ruta de transporte
        costs = [  # bars
            # 1 2 3 4 5
            [2, 4, 5, 2, 1],  # A   warehouses
            [3, 1, 3, 2, 3],  # B
            [0, 0, 0, 0, 0],
        ]

        # Los datos de costo se convierten en un diccionario
        costs = makeDict([warehouses, bars], costs, 0)

        # Crea la variable 'prob' para contener los datos del problema
        problem_name = "Beer_Distribution_Problem"
        self.problem_name = problem_name
        prob = LpProblem(problem_name, LpMinimize)

        # Crea una lista de tuplas que contienen todas las rutas posibles para transporte
        routes = [(w, b) for w in warehouses for b in bars]

        # Se crea un diccionario llamado 'Vars' para contener las variables referenciadas (las rutas)
        decision_vars = LpVariable.dicts("Route", (warehouses, bars), 0, None, LpInteger)

        # La función objetivo se agrega a 'prob' primero
        prob += (
            lpSum([decision_vars[w][b] * costs[w][b] for (w, b) in routes]),
            "Sum_of_Transporting_Costs",
        )

        # Las restricciones máximas de suministro se agregan a prob para cada nodo de suministro (almacén)
        for w in warehouses:
            prob += (
                lpSum([decision_vars[w][b] for b in bars]) <= supply[w],
                f"Sum_of_Products_out_of_Warehouse_{w}",
            )

        # Las restricciones mínimas de demanda se agregan a prob para cada nodo de demanda (bar)
        for b in bars:
            prob += (
                lpSum([decision_vars[w][b] for w in warehouses]) >= demand[b],
                f"Sum_of_Products_into_Bar{b}",
            )

        # Los datos del problema se escriben a un archivo .lp
        prob.writeLP("BeerDistributionProblem.lp")

        # El problema se resuelve usando la elección de Solver de PuLP
        prob.solve()

        self.lp_status = LpStatus[prob.status]
        self.decision_variables = prob.variables()
        self.objective_value = value(prob.objective)

    def prepare_data(self, session):
        # Entidades
        # Valores de fábricas
        factories_query = session.table("supply_chain_network_optimization_db.entities.factory").select(
            col("name")).collect()
        factories = []
        for i in range(len(factories_query)):
            factories.append(factories_query[i][0])
        self.factories = factories

        production_capacity_values_query = session.table(
            "supply_chain_network_optimization_db.entities.factory").select(
            col("production_capacity")).collect()
        production_capacity_values = []
        for i in range(len(production_capacity_values_query)):
            production_capacity_values.append(production_capacity_values_query[i][0])
        production_capacities = dict(zip(factories, production_capacity_values))
        self.production_capacities = production_capacities

        production_cost_values_query = session.table("supply_chain_network_optimization_db.entities.factory").select(
            col("production_cost")).collect()
        production_cost_values = []
        for i in range(len(production_cost_values_query)):
            production_cost_values.append(float(production_cost_values_query[i][0]))
        production_costs = dict(zip(factories, production_cost_values))
        self.production_costs = production_costs

        # Valores de distribuidores
        distributors_query = session.table("supply_chain_network_optimization_db.entities.distributor").select(
            col("name")).collect()
        distributors = []
        for i in range(len(distributors_query)):
            distributors.append(distributors_query[i][0])
        self.distributors = distributors

        throughput_capacity_values_query = session.table(
            "supply_chain_network_optimization_db.entities.distributor").select(
            col("throughput_capacity")).collect()
        throughput_capacity_values = []
        for i in range(len(throughput_capacity_values_query)):
            throughput_capacity_values.append(throughput_capacity_values_query[i][0])
        throughput_capacities = dict(zip(distributors, throughput_capacity_values))
        self.throughput_capacities = throughput_capacities

        throughput_cost_values_query = session.table(
            "supply_chain_network_optimization_db.entities.distributor").select(
            col("throughput_cost")).collect()
        throughput_cost_values = []
        for i in range(len(throughput_cost_values_query)):
            throughput_cost_values.append(float(throughput_cost_values_query[i][0]))
        throughput_costs = dict(zip(distributors, throughput_cost_values))
        self.throughput_costs = throughput_costs

        # Valores de clientes
        customers_query = session.table("supply_chain_network_optimization_db.entities.customer").select(
            col("name")).collect()
        customers = []
        for i in range(len(customers_query)):
            customers.append(customers_query[i][0])
        self.customers = customers

        demand_values_query = session.table("supply_chain_network_optimization_db.entities.customer").select(
            col("demand")).collect()
        demand_values = []
        for i in range(len(demand_values_query)):
            demand_values.append(demand_values_query[i][0])
        demand = dict(zip(customers, demand_values))
        self.demand = demand

        # Relaciones
        # Valores de flete de Fábrica a Distribuidor
        f2d_rate_values = session.sql('''select *
        from supply_chain_network_optimization_db.relationships.factory_to_distributor_rates_matrix
        order by distributor asc;''').collect()
        f2d_rates = []
        for i in range(len(factories)):
            f2d_rates.append(f2d_rate_values[i][1:len(factories)])

        f2d_costs = makeDict([factories, distributors], f2d_rates, 0)
        self.factory_to_distributor_rates = f2d_costs

        # Valores de millaje de Fábrica a Distribuidor
        f2d_mileage_values = session.sql('''select *
                from supply_chain_network_optimization_db.relationships.factory_to_distributor_mileage_matrix
                order by distributor asc;''').collect()
        f2d_mileage = []
        for i in range(len(factories)):
            f2d_mileage.append(f2d_mileage_values[i][1:len(factories)])

        f2d_distance = makeDict([factories, distributors], f2d_mileage, 0)
        self.factory_to_distributor_mileage = f2d_distance

        # Valores de flete de Distribuidor a Cliente
        d2c_rate_values = session.sql('''select *
                from supply_chain_network_optimization_db.relationships.distributor_to_customer_rates_matrix
                order by customer asc;''').collect()
        d2c_rates = []
        for i in range(len(distributors)):
            d2c_rates.append(f2d_rate_values[i][1:len(distributors)])
        d2c_costs = makeDict([distributors, customers], d2c_rates, 0)
        self.distributor_to_customer_rates = d2c_costs

        # Valores de millaje de Distribuidor a Cliente
        d2c_mileage_values = session.sql('''select *
                        from supply_chain_network_optimization_db.relationships.distributor_to_customer_mileage_matrix
                        order by customer asc;''').collect()
        d2c_mileage = []
        for i in range(len(distributors)):
            d2c_mileage.append(d2c_mileage_values[i][1:len(distributors)])
        d2c_distance = makeDict([distributors, customers], d2c_mileage, 0)
        self.distributor_to_customer_mileage = d2c_distance

    def solve(self, problem_name):
        factories = self.factories
        production_capacities = self.production_capacities
        production_costs = self.production_costs
        distributors = self.distributors
        throughput_capacities = self.throughput_capacities
        throughput_costs = self.throughput_costs
        customers = self.customers
        demand = self.demand
        factory_to_distributor_mileage = self.factory_to_distributor_mileage
        distributor_to_customer_mileage = self.distributor_to_customer_mileage
        factory_to_distributor_rates = self.factory_to_distributor_rates
        distributor_to_customer_rates = self.distributor_to_customer_rates

        # Crea la variable 'prob' para contener los datos del problema
        self.problem_name = problem_name
        prob = LpProblem(problem_name, LpMinimize)

        # Crea una lista de tuplas que contienen todas las rutas posibles para transporte
        f2d_routes = [(f, d) for f in factories for d in distributors]
        d2c_routes = [(d, c) for d in distributors for c in customers]

        # Las variables de decisión - Las decisiones que el solver cambia para decidir un resultado óptimo
        # Se crea un diccionario llamado 'Vars' para contener las variables referenciadas (las rutas)
        f2d_decision_vars = LpVariable.dicts("F2DRoute", (factories, distributors), 0, None, LpInteger)
        d2c_decision_vars = LpVariable.dicts("D2CRoute", (distributors, customers), 0, None, LpInteger)

        # La Función Objetivo - Cuál es la meta real y cómo se calcula
        # La función objetivo se agrega a 'prob' primero
        f2d_miles = lpSum([f2d_decision_vars[f][d] * factory_to_distributor_mileage[f][d] for (f, d) in f2d_routes])
        d2c_miles = lpSum([d2c_decision_vars[d][c] * distributor_to_customer_mileage[d][c] for (d, c) in d2c_routes])
        f_production = lpSum([f2d_decision_vars[f][d] * production_costs[f] for (f, d) in f2d_routes])
        f2d_freight = lpSum([f2d_decision_vars[f][d] * factory_to_distributor_rates[f][d]
                             for (f, d) in f2d_routes])
        d_throughput = lpSum([d2c_decision_vars[d][c] * throughput_costs[d] for (d, c) in d2c_routes])
        d2c_freight = lpSum([d2c_decision_vars[d][c] * distributor_to_customer_rates[d][c]
                             for (d, c) in d2c_routes])

        # Determinar qué objetivo basado en el problema
        if problem_name == "Minimize_Distance":
            prob += (
                f2d_miles + d2c_miles,
                "Sum_of_Transporting_Distance",
            )
        elif problem_name == "Minimize_Freight":
            prob += (
                f2d_freight + d2c_freight,
                "Sum_of_Freight",
            )
        elif problem_name == "Minimize_Total_Fulfillment":
            prob += (
                f_production + f2d_freight + d_throughput + d2c_freight,
                "Sum_of_Fulfillment_Costs",
            )

        # Sección de Restricciones - Los límites que definen las realidades del negocio
        # Las fábricas solo pueden enviar tanto como pueden producir
        for f in factories:
            prob += (
                lpSum([f2d_decision_vars[f][d] for d in distributors]) <= production_capacities[f],
                f"Sum_of_Products_out_of_Factory_{f}",
            )

        # Las fábricas solo pueden enviar a distribuidores hasta su capacidad de rendimiento
        for d in distributors:
            prob += (
                lpSum([f2d_decision_vars[f][d] for f in factories]) <= throughput_capacities[d],
                f"Sum_of_Products_into_Distributor_{d}",
            )

        # Los distribuidores necesitan tener inventario reabastecido
        for d in distributors:
            prob += (
                    lpSum([f2d_decision_vars[f][d] for f in factories]) >= lpSum([d2c_decision_vars[d][c] for c in
                                                                                  customers])
            )

        # Los distribuidores solo pueden enviar su capacidad de rendimiento
        for d in distributors:
            prob += (
                lpSum([d2c_decision_vars[d][c] for c in customers]) <= throughput_capacities[d],
                f"Sum_of_Products_out_of_Distributor_{d}",
            )

        # La demanda del cliente debe ser cubierta
        for c in customers:
            prob += (
                lpSum([d2c_decision_vars[d][c] for d in distributors]) >= demand[c],
                f"Sum_of_Products_to_Customer_{c}",
            )

        # Los datos del problema se escriben a un archivo .lp
        prob.writeLP(problem_name + ".lp")

        # El problema se resuelve usando la elección de Solver de PuLP
        prob.solve()

        self.total_f2d_miles = value(f2d_miles)
        self.total_d2c_miles = value(d2c_miles)
        self.total_production_costs = value(f_production)
        self.total_f2d_freight = value(f2d_freight)
        self.total_throughput_costs = value(d_throughput)
        self.total_d2c_freight = value(d2c_freight)

        self.lp_status = LpStatus[prob.status]
        self.decision_variables = prob.variables()
        try:
            self.objective_value = value(prob.objective)
        except:
            self.objective_value = None


class Page(ABC):
    @abstractmethod
    def __init__(self):
        pass

    @abstractmethod
    def print_page(self):
        pass

    @abstractmethod
    def print_sidebar(self):
        pass


def set_default_sidebar():
    # Barra lateral para navegar páginas
    with st.sidebar:
        st.title("Optimización de Red de Cadena de Suministro 🐻‍❄")
        st.markdown("")
        st.markdown("Esta aplicación configura y ejecuta modelos de optimización de red de 3 niveles.")
        st.markdown("")
        if st.button(label="Preparación de Datos 🗃️", help="Advertencia: ¡Los cambios no guardados se perderán!"):
            set_page('Preparación de Datos')
            st.rerun()
        if st.button(label="Parámetros del Modelo 🧮", help="Advertencia: ¡Los cambios no guardados se perderán!"):
            set_page('Parámetros del Modelo')
            st.rerun()
        if st.button(label="Ejecución del Modelo 🚀", help="Advertencia: ¡Los cambios no guardados se perderán!"):
            set_page('Ejecución del Modelo')
            st.rerun()
        if st.button(label="Resultados del Modelo 📊", help="Advertencia: ¡Los cambios no guardados se perderán!"):
            set_page('Resultados del Modelo')
            st.rerun()
        if st.button(label="Enriquecimiento Cortex 🤖", help="Advertencia: ¡Los cambios no guardados se perderán!"):
            set_page('Enriquecimiento Cortex')
            st.rerun()
        st.markdown("")
        st.markdown("")
        st.markdown("")
        st.markdown("")
        if st.button(label="Regresar al Inicio", help="Advertencia: ¡Los cambios no guardados se perderán!"):
            set_page('Bienvenida')
            st.rerun()


class WelcomePage(Page):
    def __init__(self):
        self.name = "Bienvenida"

    def print_page(self):
        # Configurar página principal
        col1, col2 = st.columns((6, 1))
        col1.title("Optimización de Red de Cadena de Suministro 🐻‍❄️")

        # Página de bienvenida
        st.subheader("Bienvenida ❄️")

        st.write('''El Modelo de Optimización de Red de Cadena de Suministro utiliza [Programación Lineal](
        https://en.wikipedia.org/wiki/Linear_programming), también llamada optimización lineal o programación con restricciones.''')

        st.write('''La programación lineal usa un sistema de desigualdades para definir un espacio matemático regional factible, y un
        'solver' que recorre ese espacio ajustando una serie de variables de decisión, encontrando eficientemente el conjunto más óptimo
        de decisiones dadas las restricciones para cumplir con una función objetivo establecida.''')

        st.write('''También es posible introducir variables de decisión basadas en enteros, lo que transforma el problema de un programa lineal
        a un programa entero mixto, pero la mecánica es fundamentalmente la misma.''')

        st.write("La función objetivo define la meta - maximizar o minimizar un valor, como la ganancia o los costos.")
        st.write("Las variables de decisión son un conjunto de decisiones - los valores que el solver puede cambiar para impactar "
                 "el valor objetivo.")
        st.write(
            "Las restricciones definen las realidades del negocio - como enviar solo hasta una capacidad establecida.")

        st.write("Estamos utilizando la biblioteca PuLP, que nos permite definir un programa lineal y usar virtualmente cualquier "
                 "solver que queramos. Estamos usando el solver CBC gratuito predeterminado de PuLP [CBC solver](https://github.com/coin-or/Cbc) para nuestros "
                 "modelos.")

        with st.expander("Recursos Adicionales", expanded=True):
            st.write("¿Interesado en [Programación de Optimización usando PuLP](https://coin-or.github.io/pulp/)?")

    def print_sidebar(self):
        set_default_sidebar()


class DataPreparationPage(Page):
    def __init__(self):
        self.name = "Preparación de Datos"

    def print_page(self):
        def deploy_demo_data(customer_count, session):
            customer_list = []
            for i in range(0, customer_count):
                coordinates_list = fake.local_latlng()
                cust_id = operator.add(i, 3001)
                lat = coordinates_list[0]
                lon = coordinates_list[1]
                long_lat = "POINT (" + coordinates_list[1] + " " + coordinates_list[0] + ")"
                name = str(fake.company()) + "_" + str(i)
                demand = randint(1, 100)
                customer_list.append([cust_id, name, lon, lat, long_lat, demand])

            # Configurar base de datos
            data = session.create_dataframe(customer_list, schema=["ID", "NAME", "LATITUDE", "LONGITUDE",
                                                                   "LONG_LAT", "DEMAND"])
            data.write.mode("overwrite").saveAsTable("entities.customer")
            session.sql(factories_sql).collect()
            session.sql(distributor_sql).collect()

            session.sql(fact_to_dist_sql).collect()
            session.sql(dist_to_cust_sql).collect()

            sync_factory_data(session)
            sync_distributor_data(session)

            # Almacenar clientes para mostrar en UI
            st.session_state.customer_data = customer_list

        def sync_factory_data(session):
            fact_to_dist_rate_pivot_sql = session.sql(fact_to_dist_rate_matrix_sql).collect()[0][0]
            session.sql(fact_to_dist_rate_pivot_sql).collect()

            fact_to_dist_mileage_pivot_sql = session.sql(fact_to_dist_mileage_matrix_sql).collect()[0][0]
            session.sql(fact_to_dist_mileage_pivot_sql).collect()

        def sync_distributor_data(session):
            dist_to_cust_rate_pivot_sql = session.sql(dist_to_cust_rate_matrix_sql).collect()[0][0]
            session.sql(dist_to_cust_rate_pivot_sql).collect()

            dist_to_cust_mileage_pivot_sql = session.sql(dist_to_cust_mileage_matrix_sql).collect()[0][0]
            session.sql(dist_to_cust_mileage_pivot_sql).collect()

        col1, col2 = st.columns((6, 1))
        col1.title("Optimización de Red de Cadena de Suministro 🐻‍❄️")

        st.subheader("Generemos Algunos Datos ❄️")

        st.write("Lo siguiente configurará todos los objetos de datos en Snowflake para el modelo, incluyendo generar un "
                 "conjunto sintético de clientes.")

        st.write("Hay cierta aleatoriedad asociada con la generación de datos, por lo que es posible obtener "
                 "resultados inviables si se crean demasiados clientes. El número y capacidades de fábricas y distribuidores "
                 "están fijos. Recomendamos usar 1000 para un modelo viable, pero siéntete libre de aumentar "
                 "para ver cómo se ven los resultados inviables. También, usando la página de Parámetros del Modelo, "
                 "puedes aumentar las capacidades para hacer más clientes viables.")

        count_column, submit_column = st.columns(2)

        customer_count = count_column.number_input(label="¿Cuántos clientes de prueba te gustaría incluir?",
                                                   min_value=1,
                                                   max_value=1000000, value=1000)
        submit_column.write(" #")

        if submit_column.button("Generar Datos"):
            with st.spinner("Generando Datos Sintéticos de Clientes..."):
                deploy_demo_data(customer_count, session)
                df = pd.DataFrame(st.session_state.customer_data,
                                  columns=["ID", "LONGITUDE", "LATITUDE", "LAT_LONG", "NAME", "DEMAND"])
                st.dataframe(df)

    def print_sidebar(self):
        set_default_sidebar()


class ModelParametersPage(Page):
    def __init__(self):
        self.name = "Parámetros del Modelo"

    def print_page(self):
        col1, col2 = st.columns((6, 1))
        col1.title("Optimización de Red de Cadena de Suministro 🐻‍❄️")

        # Usado para ver y modificar valores del modelo dentro de Snowflake
        st.subheader("Parámetros del Modelo ❄️")

        factory_tab, distributor_tab, customer_tab, f2d_rates_tab, d2c_rates_tab = st.tabs(["Fábricas", "Distribuidores",
                                                                                            "Clientes", "Tarifas F2D",
                                                                                            "Tarifas D2C"])
        with st.spinner("Recuperando Valores de Filtros..."):
            factories_query = session.table("supply_chain_network_optimization_db.entities.factory").select(
                col("name")).collect()
            factories = []
            for i in range(len(factories_query)):
                factories.append(factories_query[i][0])

            distributors_query = session.table("supply_chain_network_optimization_db.entities.distributor").select(
                col("name")).collect()
            distributors = []
            for i in range(len(distributors_query)):
                distributors.append(distributors_query[i][0])

            customers_query = session.table("supply_chain_network_optimization_db.entities.customer").select(
                col("name")).collect()
            customers = []
            for i in range(len(customers_query)):
                customers.append(customers_query[i][0])

        with factory_tab:
            results = session.table("supply_chain_network_optimization_db.entities.factory")
            st.write(results)

        with distributor_tab:
            results = session.table("supply_chain_network_optimization_db.entities.distributor")
            st.write(results)

        with customer_tab:
            results = session.table("supply_chain_network_optimization_db.entities.customer")
            st.write(results)

        with f2d_rates_tab:
            factory_name = st.selectbox("Elige un nombre de fábrica", factories)

            results = session.table(
                "supply_chain_network_optimization_db.relationships.factory_to_distributor_rates").filter(
                col("factory") == factory_name)
            st.write(results)

        with d2c_rates_tab:
            distributor_name = st.selectbox("Elige un nombre de distribuidor", distributors)

            results = session.table(
                "supply_chain_network_optimization_db.relationships.distributor_to_customer_rates").filter(
                col("distributor") == distributor_name)
            st.write(results)

        st.write("¡Después de actualizar los parámetros, por favor continúa con la ejecución del modelo!")

    def print_sidebar(self):
        set_default_sidebar()


class ModelExecutionPage(Page):
    def __init__(self):
        self.name = "Ejecución del Modelo"

    def print_page(self):
        col1, col2 = st.columns((6, 1))
        col1.title("Optimización de Red de Cadena de Suministro 🐻‍❄️")

        # Se conecta a Snowflake, prepara los datos del modelo y ejecuta el modelo
        st.subheader("Ejecución del Modelo ❄️")

        with st.form("model_parameters_form"):
            st.write("El ejecutor del modelo ejecuta tres escenarios diferentes:")
            st.write("-- Minimizar Distancia (Gatear) - Emulando un presente bastante ingenuo")
            st.write("-- Minimizar Flete (Caminar) - Emulando una organización con capacidad de análisis de flete")
            st.write("-- Minimizar Cumplimiento Total (Correr) - Emulando una capacidad de análisis de red completamente realizada")

            submitted = st.form_submit_button("Ejecutar")

            col_dict = {
                "Minimize_Distance": "distance_col",
                "Minimize_Freight": "freight_col",
                "Minimize_Total_Fulfillment": "fulfillment_col",
            }

            if submitted:
                if session.table("supply_chain_network_optimization_db.entities.customer").count() > 0:
                    with st.spinner("Resolviendo Modelos..."):
                        model = OptimizationModel()
                        model.prepare_data(session)

                        model_count = 1
                        for current_model in ["Minimize_Distance", "Minimize_Freight", "Minimize_Total_Fulfillment"]:
                            model.solve(current_model)

                            decision_variables = []

                            for v in model.decision_variables:
                                variant = {v.name: v.varValue}
                                decision_variables.append(variant)

                            run_date = datetime.datetime.now()

                            model_list = [[model.problem_name, run_date, model.lp_status, model.objective_value,
                                           decision_variables, model.total_f2d_miles, model.total_d2c_miles,
                                           model.total_production_costs, model.total_f2d_freight,
                                           model.total_throughput_costs,
                                           model.total_d2c_freight]]

                            model_df = session.create_dataframe(model_list, schema=["problem_name",
                                                                                    "run_date",
                                                                                    "lp_status",
                                                                                    "objective_value",
                                                                                    "decision_variables",
                                                                                    "total_f2d_miles",
                                                                                    "total_d2c_miles",
                                                                                    "total_production_costs",
                                                                                    "total_f2d_freight",
                                                                                    "total_throughput_costs",
                                                                                    "total_d2c_freight"])
                            model_df.write.mode("append").saveAsTable("results.model_results")

                            st.subheader("Nombre del Modelo: " + model.problem_name)

                            # El estado de la solución se imprime en la pantalla
                            st.write("Estado: ", model.lp_status)

                            # Cada una de las variables se imprime con su valor óptimo resuelto
                            st.write("Decisiones Tomadas: ", len(model.decision_variables))

                            with st.expander("Muestra de Decisiones: "):
                                # El valor de la función objetivo optimizada se imprime en la pantalla
                                st.write("Valor Objetivo (basado en la meta): ", model.objective_value)

                                variable_count = 0
                                for v in model.decision_variables:
                                    while variable_count <= 1000:
                                        st.write(v.name, "=", v.varValue)
                                        variable_count += 1

                            total_fulfillment_costs = model.total_production_costs + model.total_f2d_freight + \
                                                      model.total_throughput_costs + model.total_d2c_freight

                            st.write("Costos Totales de Cumplimiento: ", total_fulfillment_costs)

                            with st.expander("Detalles de Resultados: "):
                                st.write("Millas de Fábrica-a-Distribuidor: ", model.total_f2d_miles)
                                st.write("Millas de Distribuidor-a-Cliente: ", model.total_d2c_miles)
                                st.write("Costos Totales de Producción: ", model.total_production_costs)
                                st.write("Flete Total de Fábrica-a-Distribuidor: ", model.total_f2d_freight)
                                st.write("Costos Totales de Rendimiento del Distribuidor: ", model.total_throughput_costs)
                                st.write("Flete Total de Distribuidor-a-Cliente: ", model.total_d2c_freight)

                    st.success("¡Modelos Resueltos!")
                    st.snow()
                else:
                    st.warning("Los datos no están cargados, por favor regresa a Preparación de Datos y genera datos de clientes "
                               "primero.")

        st.write("¡Después de ejecutar los modelos, por favor continúa con los resultados!")

    def print_sidebar(self):
        set_default_sidebar()


class ModelResultsPage(Page):
    def __init__(self):
        self.name = "Resultados del Modelo"

    def print_page(self):
        col1, col2 = st.columns((6, 1))
        col1.title("Optimización de Red de Cadena de Suministro 🐻‍❄️")

        # Usado para ver y analizar los resultados
        st.subheader("Resultados del Modelo ❄️")

        problem_name_col, run_date_col = st.columns(2)

        problem_name_query = session.table(
            "supply_chain_network_optimization_db.results.factory_to_distributor_shipment_details_vw").select(
            col("problem_name")).distinct().collect()
        problem_names = []
        for i in range(len(problem_name_query)):
            problem_names.append(problem_name_query[i][0])

        with problem_name_col:
            problem_name = st.selectbox("Selecciona un Nombre de Problema", problem_names)

        run_date_query = session.table(
            "supply_chain_network_optimization_db.results.factory_to_distributor_shipment_details_vw").filter(
            col("problem_name") == problem_name).select(col("run_date")).distinct().sort(col("run_date").desc()) \
            .collect()
        run_dates = []
        for i in range(len(run_date_query)):
            run_dates.append(run_date_query[i][0])

        with run_date_col:
            run_date = st.selectbox("Selecciona una Fecha de Ejecución", run_dates)

        f2d_results_df = session.table(
            "supply_chain_network_optimization_db.results.factory_to_distributor_shipment_details_vw").filter(
            col("problem_name") == problem_name).filter(col("run_date") == run_date)
        c2d_results_df = session.table(
            "supply_chain_network_optimization_db.results.distributor_to_customer_shipment_details_vw").filter(
            col("problem_name") == problem_name).filter(col("run_date") == run_date)

        factories_query = session.table(
            "supply_chain_network_optimization_db.results.factory_to_distributor_shipment_details_vw").select(
            col("factory_name")).distinct().sort(col("factory_name").asc()).collect()
        factories = [""]
        for i in range(len(factories_query)):
            factories.append(factories_query[i][0])

        distributors_query = session.table(
            "supply_chain_network_optimization_db.results.factory_to_distributor_shipment_details_vw").select(
            col("distributor_name")).distinct().sort(col("distributor_name").asc()).collect()
        distributors = [""]
        for i in range(len(distributors_query)):
            distributors.append(distributors_query[i][0])

        customers_query = session.table(
            "supply_chain_network_optimization_db.results.distributor_to_customer_shipment_details_vw").select(
            col("customer_name")).distinct().sort(col("customer_name").asc()).collect()
        customers = [""]
        for i in range(len(customers_query)):
            customers.append(customers_query[i][0])

        factory_filter_col, distributor_filter_col, customer_filter_col = st.columns(3)

        with factory_filter_col:
            factory_name = st.selectbox("Elige un nombre de fábrica", factories)
        with distributor_filter_col:
            distributor_name = st.selectbox("Elige un nombre de distribuidor", distributors)
        with customer_filter_col:
            customer_name = st.selectbox("Elige un nombre de cliente", customers)

        # Tablas
        st.subheader("Tablas de Envíos")
        fact_to_dist_col, dist_to_cust_col = st.columns(2)

        with fact_to_dist_col:
            st.write("Cantidad enviada de Fábricas a Distribuidores:")
            st.write(f2d_results_df.select(col("factory_name"), col("distributor_name"),
                                           col("factory_to_distributor_shipped_amount"))
                     .filter(col("factory_to_distributor_shipped_amount") > 0)
                     .filter((col("factory_name") == factory_name) | (factory_name == ""))
                     .filter((col("distributor_name") == distributor_name) | (distributor_name == ""))
                     .collect())

        with dist_to_cust_col:
            st.write("Cantidad enviada de Distribuidores a Clientes:")
            st.write(c2d_results_df.select(col("distributor_name"), col("customer_name"),
                                           col("distributor_to_customer_shipped_amount"))
                     .filter(col("distributor_to_customer_shipped_amount") > 0)
                     .filter((col("distributor_name") == distributor_name) | (distributor_name == ""))
                     .filter((col("customer_name") == customer_name) | (customer_name == ""))
                     .collect())

        # Mapas
        st.subheader("Mapas de Envíos")
        factory_map_col, distributor_map_col, customer_map_col = st.columns(3)

        if f2d_results_df.count() > 0:
            with factory_map_col:
                st.map(f2d_results_df
                       .filter(col("factory_to_distributor_shipped_amount") > 0)
                       .filter((col("factory_name") == factory_name) | (factory_name == ""))
                       .filter((col("distributor_name") == distributor_name) | (distributor_name == ""))
                       .select(col("factory_latitude").cast("float").alias("latitude"),
                               col("factory_longitude").cast("float").alias("longitude")).collect())

        if c2d_results_df.count() > 0:
            with distributor_map_col:
                st.map(c2d_results_df
                       .filter(col("distributor_to_customer_shipped_amount") > 0)
                       .filter((col("distributor_name") == distributor_name) | (distributor_name == ""))
                       .select(col("distributor_latitude").cast("float").alias("latitude"),
                               col("distributor_longitude").cast("float").alias("longitude")).collect())

        if c2d_results_df.count() > 0:
            with customer_map_col:
                st.map(c2d_results_df
                       .filter(col("distributor_to_customer_shipped_amount") > 0)
                       .filter((col("distributor_name") == distributor_name) | (distributor_name == ""))
                       .filter((col("customer_name") == customer_name) | (customer_name == ""))
                       .select(col("customer_latitude").cast("float").alias("latitude"),
                               col("customer_longitude").cast("float").alias("longitude")).collect())

    def print_sidebar(self):
        set_default_sidebar()


class CortexPage(Page):
    def __init__(self):
        self.name = "Enriquecimiento Cortex"

    def print_page(self):

        closest_airport_sql = '''select
        id
    ,   snowflake.cortex.complete(
        'llama2-70b-chat',
        concat('Una fábrica está ubicada en ', city, ', ', state, ', ', country, ' en latitud ', latitude, ' y longitud ', longitude, '.  Dadas esas coordenadas geográficas, ¿cuál es el aeropuerto más cercano?  Solo puedes responder con el nombre del aeropuerto, nada más.  No expliques la respuesta.  No agregues comentarios.  No incluyas una nota.  No respondas en una oración.')) as closest_airport
from supply_chain_network_optimization_db.entities.factory'''
        closest_interstate_sql = '''select
        id
    ,   snowflake.cortex.complete(
        'llama2-70b-chat',
        concat('A factory is located in ', city, ', ', state, ', ', country, ' at latitude ', latitude, ' and longitude ', longitude, '.  Given that latitude and longitude represent geographic coordinates, what is the closest interstate?  You are only allowed to respond with the name of the interstate, nothing more.  Do not explain the answer.  Do not add comments.  Do not include a note.  Do not reply in a sentence.')) as closest_interstate
from supply_chain_network_optimization_db.entities.factory'''
        closest_river_sql = '''select
        id
    ,   snowflake.cortex.complete(
        'llama2-70b-chat',
        concat('A factory is located in ', city, ', ', state, ', ', country, ' at latitude ', latitude, ' and longitude ', longitude, '.  Given that latitude and longitude represent geographic coordinates, what is the closest river?  You are only allowed to respond with the name of the river, nothing more.  Do not explain the answer.  Do not add comments.  Do not include a note.  Do not reply in a sentence.  Simply respond with the name of the river.')) as closest_river
from supply_chain_network_optimization_db.entities.factory'''
        average_temperature_sql = '''select
        id
    ,   regexp_substr(snowflake.cortex.complete(
        'llama2-70b-chat',
        concat('A factory is located in ', city, ', ', state, ', ', country, ' at latitude ', latitude, ' and longitude ', longitude, '.  Given that latitude and longitude represent geographic coordinates, what is the average annual temperature in fahrenheit?  Format your answer as a number without text.  Do not include celsius.  Do not explain the answer.  Do not add comments.  Do not include a note.  Do not reply in a sentence.  Only reply with a number.')),'[0-9]{1,3}\\.?[0-9]?') as average_temperature
from supply_chain_network_optimization_db.entities.factory'''
        average_rainfall_sql = '''select
        id
    ,   regexp_substr(snowflake.cortex.complete(
        'llama2-70b-chat',
        concat('A factory is located in ', city, ', ', state, ', ', country, ' at latitude ', latitude, ' and longitude ', longitude, '.  Given that latitude and longitude represent geographic coordinates, what is the average annual rainfall in inches?  Format your answer as a number without text.  Do not explain the answer.  Do not add comments.  Do not include a note.  Do not reply in a sentence.  Only reply with a number.')),'[0-9]{1,4}\\.?[0-9]?') as average_rainfall
from supply_chain_network_optimization_db.entities.factory'''

        sql_statements = {
                "Closest Airport": closest_airport_sql
            ,   "Closest Interstate": closest_interstate_sql
            ,   "Closest River": closest_river_sql
            ,   "Average Temperature": average_temperature_sql
            ,   "Average Rainfall": average_rainfall_sql
        }

        prompt_examples = {
                "Aeropuerto Más Cercano": """Una fábrica está ubicada en Bogotá, Cundinamarca, Colombia en latitud 4.7110 y longitud -74.0721. Dadas esas coordenadas geográficas, ¿cuál es el aeropuerto más cercano? Solo puedes responder con el nombre del aeropuerto, nada más. No expliques la respuesta. No agregues comentarios. No incluyas una nota. No respondas en una oración."""
            ,   "Autopista Más Cercana": """Una fábrica está ubicada en Bogotá, Cundinamarca, Colombia en latitud 4.7110 y longitud -74.0721. Dadas esas coordenadas geográficas, ¿cuál es la autopista más cercana? Solo puedes responder con el nombre de la autopista, nada más. No expliques la respuesta. No agregues comentarios. No incluyas una nota. No respondas en una oración."""
            ,   "Río Más Cercano": """Una fábrica está ubicada en Bogotá, Cundinamarca, Colombia en latitud 4.7110 y longitud -74.0721. Dadas esas coordenadas geográficas, ¿cuál es el río más cercano? Solo puedes responder con el nombre del río, nada más. No expliques la respuesta. No agregues comentarios. No incluyas una nota. No respondas en una oración. Simplemente responde con el nombre del río."""
            ,   "Temperatura Promedio": """Una fábrica está ubicada en Bogotá, Cundinamarca, Colombia en latitud 4.7110 y longitud -74.0721. Dadas esas coordenadas geográficas, ¿cuál es la temperatura anual promedio en grados Celsius? Formatea tu respuesta como un número sin texto. No incluyas Fahrenheit. No expliques la respuesta. No agregues comentarios. No incluyas una nota. No respondas en una oración. Solo responde con un número."""
            ,   "Precipitación Promedio": """Una fábrica está ubicada en Bogotá, Cundinamarca, Colombia en latitud 4.7110 y longitud -74.0721. Dadas esas coordenadas geográficas, ¿cuál es la precipitación anual promedio en milímetros? Formatea tu respuesta como un número sin texto. No expliques la respuesta. No agregues comentarios. No incluyas una nota. No respondas en una oración. Solo responde con un número."""
        }

        col1, col2 = st.columns((6, 1))
        col1.title("Optimización de Red de Cadena de Suministro 🐻‍❄️")

        # Usado para analizar resultados con Cortex
        st.subheader("Enriquecimiento Cortex ❄️")

        st.info("La siguiente página incluye las funciones del Modelo de Lenguaje Grande (LLM) de Cortex, que están en *Vista Previa*")

        st.write("Enriquezcamos nuestra información sobre nuestras fábricas para ver si podemos obtener mayor contexto para la cadena "
                 "de suministro.")

        if "factory_df" not in st.session_state:
            st.session_state.factory_df = session.table("supply_chain_network_optimization_db.entities.factory")\
                .select(col("id"), col("name"), col("latitude"), col("longitude"), col("city"), col("state"), col("country"))\
                .distinct()

        with st.form("EnrichmentForm"):
            st.subheader("Selección de Enriquecimiento")

            st.write("Elige qué campos te gustaría agregar a los datos de las fábricas.")
            st.write("Los datos serán proporcionados a través de Cortex, usando el modelo llama2-70b-chat. Revisa el expansor abajo para ver los "
                     "prompts/consultas directamente.")

            add_closest_airport = st.checkbox("Aeropuerto Más Cercano", value=False)
            add_closest_interstate = st.checkbox("Autopista Más Cercana", value=False)
            add_closest_river = st.checkbox("Río Más Cercano", value=False)
            add_average_temperature = st.checkbox("Temperatura Promedio", value=False)
            add_average_rainfall = st.checkbox("Precipitación Promedio", value=False)

            submitted = st.form_submit_button("Enriquecer")

            if submitted:
                factory_df = st.session_state.factory_df

                if add_closest_airport:
                    closest_airport_df = session.sql(closest_airport_sql)
                    factory_df = factory_df.join(closest_airport_df, factory_df.id == closest_airport_df.id, rsuffix="_airport")

                if add_closest_interstate:
                    closest_interstate_df = session.sql(closest_interstate_sql)
                    factory_df = factory_df.join(closest_interstate_df, factory_df.id == closest_interstate_df.id, rsuffix="_interstate")

                if add_closest_river:
                    closest_river_df = session.sql(closest_river_sql)
                    factory_df = factory_df.join(closest_river_df, factory_df.id == closest_river_df.id, rsuffix="_river")

                if add_average_temperature:
                    average_temperature_df = session.sql(average_temperature_sql)
                    factory_df = factory_df.join(average_temperature_df, factory_df.id == average_temperature_df.id, rsuffix="_temperature")

                if add_average_rainfall:
                    average_rainfall_df = session.sql(average_rainfall_sql)
                    factory_df = factory_df.join(average_rainfall_df, factory_df.id == average_rainfall_df.id, rsuffix="_rainfall")

                st.dataframe(factory_df)

        with st.expander("Ver las consultas en sí"):
            selected_query = st.selectbox("¿Qué consulta te gustaría ver?", sql_statements.keys())
            st.code(sql_statements[selected_query])

            st.write("Ejemplo de Prompt")
            st.caption(prompt_examples[selected_query])

    def print_sidebar(self):
        set_default_sidebar()


pages = [WelcomePage(), DataPreparationPage(), ModelParametersPage(), ModelExecutionPage(), ModelResultsPage(), CortexPage()]


def main():
    for page in pages:
        if page.name == st.session_state.page:
            page.print_page()
            page.print_sidebar()


main()

$$);

/* agregar archivo de entorno para streamlit - incluye todas las referencias a librerías que necesita Streamlit */
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

/* colocar archivos en el stage */
call supply_chain_network_optimization_db.code.put_to_stage('supply_chain_network_optimization_db.streamlit.streamlit_stage','streamlit_ui.py', (select script from supply_chain_network_optimization_db.code.script where name = 'STREAMLIT_V1'));
call supply_chain_network_optimization_db.code.put_to_stage('supply_chain_network_optimization_db.streamlit.streamlit_stage','environment.yml', (select script from supply_chain_network_optimization_db.code.script where name = 'ENVIRONMENT_V1'));

/* crear streamlit */
create or replace streamlit supply_chain_network_optimization_db.streamlit.supply_chain_network_optimization
  root_location = '@supply_chain_network_optimization_db.streamlit.streamlit_stage'
  main_file = '/streamlit_ui.py'
  query_warehouse = scno_wh
  comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
