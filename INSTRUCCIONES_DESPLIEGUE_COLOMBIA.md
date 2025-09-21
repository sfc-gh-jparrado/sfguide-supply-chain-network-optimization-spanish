# 🇨🇴 Despliegue del Modelo Colombiano en Snowflake

## 📋 Resumen de Cambios Realizados

### 🏭 **Fábricas Colombianas (10 ubicaciones)**
1. **Bogotá, Cundinamarca** - Capacidad: 12,000 | Costo: 850
2. **Medellín, Antioquia** - Capacidad: 10,000 | Costo: 780  
3. **Cali, Valle del Cauca** - Capacidad: 9,500 | Costo: 720
4. **Barranquilla, Atlántico** - Capacidad: 8,000 | Costo: 690
5. **Cartagena, Bolívar** - Capacidad: 7,500 | Costo: 710
6. **Bucaramanga, Santander** - Capacidad: 6,500 | Costo: 680
7. **Pereira, Risaralda** - Capacidad: 5,500 | Costo: 650
8. **Manizales, Caldas** - Capacidad: 5,000 | Costo: 630
9. **Ibagué, Tolima** - Capacidad: 4,500 | Costo: 600
10. **Villavicencio, Meta** - Capacidad: 4,000 | Costo: 580

### 🏪 **Distribuidores Colombianos (25 ubicaciones)**
- **Región Andina**: Bogotá, Medellín, Cali, Bucaramanga, Pereira, Manizales, Ibagué, Villavicencio, Tunja
- **Región Caribe**: Barranquilla, Cartagena, Santa Marta, Montería, Sincelejo, Valledupar
- **Región Pacífica**: Quibdó, Popayán, Pasto
- **Región Orinoquía**: Villavicencio, Yopal, Arauca, Puerto Carreño
- **Región Amazonía**: Leticia, Florencia, Mocoa

### 🎯 **Características Técnicas**
- ✅ Coordenadas geográficas reales de Colombia
- ✅ Capacidades adaptadas al contexto económico colombiano
- ✅ Costos ajustados al mercado local
- ✅ Ejemplos de Cortex con Bogotá como referencia
- ✅ Prompts en español con unidades métricas (°C, mm)
- ✅ Funcionalidad técnica 100% preservada

## 🚀 Instrucciones de Despliegue

### **Opción 1: Despliegue Completo (Recomendado)**

1. **Abrir Snowsight**
   - Navega a https://app.snowflake.com/
   - Inicia sesión con usuario **ACCOUNTADMIN**

2. **Ejecutar Script Completo**
   ```sql
   -- Copiar y pegar TODO el contenido del archivo app_setup.sql
   -- El script ejecutará automáticamente:
   -- ✅ Configuración de roles y permisos
   -- ✅ Creación de base de datos y esquemas
   -- ✅ Creación de tablas y vistas
   -- ✅ Inserción de datos colombianos
   -- ✅ Despliegue de aplicación Streamlit
   ```

3. **Verificar Despliegue**
   ```sql
   -- Verificar que las fábricas están en Colombia
   SELECT city, state, country, production_capacity 
   FROM supply_chain_network_optimization_db.entities.factory 
   ORDER BY production_capacity DESC;
   
   -- Verificar que los distribuidores están en Colombia  
   SELECT city, state, country, throughput_capacity
   FROM supply_chain_network_optimization_db.entities.distributor 
   ORDER BY throughput_capacity DESC;
   ```

### **Opción 2: Despliegue Paso a Paso**

#### **PASO 1: Configurar Roles**
```sql
use role accountadmin;
call system$wait(10);
create warehouse if not exists scno_wh WAREHOUSE_SIZE=SMALL;
create role if not exists scno_role;
grant create share on account to role scno_role;
grant import share on account to role scno_role;
grant create database on account to role scno_role with grant option;
grant execute task on account to role scno_role;
grant create application package on account to role scno_role;
grant create application on account to role scno_role;
grant create data exchange listing on account to role scno_role;
grant database role snowflake.cortex_user to role scno_role;
grant role scno_role to role sysadmin;
grant usage, operate on warehouse scno_wh to role scno_role;
```

#### **PASO 2: Crear Base de Datos**
```sql
use role scno_role;
use warehouse scno_wh;
create or replace database supply_chain_network_optimization_db;
create or replace schema supply_chain_network_optimization_db.entities;
create or replace schema supply_chain_network_optimization_db.relationships;
create or replace schema supply_chain_network_optimization_db.results;
create or replace schema supply_chain_network_optimization_db.code;
create or replace schema supply_chain_network_optimization_db.streamlit;
create or replace stage supply_chain_network_optimization_db.streamlit.streamlit_stage;
```

#### **PASO 3: Continuar con el resto del script app_setup.sql**

## 🌟 Acceso a la Aplicación

1. **En Snowsight, cambiar rol a `SCNO_ROLE`**
2. **Navegar a "Proyectos" → "Streamlit"**
3. **Seleccionar `SUPPLY_CHAIN_NETWORK_OPTIMIZATION`**
4. **¡La aplicación se abrirá mostrando el modelo colombiano!**

## 🗺️ Cobertura Geográfica del Modelo

### **Región Andina**
- Bogotá (Capital) - Principal hub logístico
- Medellín - Centro industrial
- Cali - Puerta al Pacífico
- Bucaramanga - Centro del oriente

### **Región Caribe**
- Barranquilla - Puerto principal del Caribe
- Cartagena - Puerto industrial
- Santa Marta - Puerto turístico y comercial

### **Región Pacífica**
- Quibdó - Centro del Chocó
- Popayán - Centro del Cauca
- Pasto - Frontera con Ecuador

### **Región Orinoquía**
- Villavicencio - Puerta a los Llanos
- Yopal - Centro petrolero
- Arauca - Frontera con Venezuela

### **Región Amazonía**
- Leticia - Frontera amazónica
- Florencia - Centro del Caquetá
- Mocoa - Centro del Putumayo

## ✅ Verificación del Modelo

Una vez desplegado, el modelo incluirá:
- ✅ **10 fábricas** estratégicamente ubicadas en Colombia
- ✅ **25 distribuidores** cubriendo todas las regiones
- ✅ **Cálculos automáticos** de distancias y costos de flete
- ✅ **Optimización** basada en geografía colombiana real
- ✅ **Interfaz en español** completamente localizada
- ✅ **Ejemplos de Cortex** adaptados a Colombia

## 🎯 Próximos Pasos

1. Ejecutar el despliegue siguiendo las instrucciones
2. Generar datos sintéticos de clientes colombianos
3. Ejecutar los modelos de optimización
4. Analizar los resultados del modelo colombiano
5. Utilizar Cortex para enriquecimiento geográfico

¡El modelo está listo para optimizar cadenas de suministro en el contexto colombiano! 🇨🇴🚀
