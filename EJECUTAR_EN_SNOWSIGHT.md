# 🚀 Ejecutar app_setup.sql en Snowsight

## ⚡ Método Recomendado (Más Confiable)

### **PASO 1: Abrir Snowsight**
1. Ve a: https://app.snowflake.com/
2. Inicia sesión con **JPARRADO** en cuenta **HQB73140**

### **PASO 2: Configurar Entorno**
```sql
USE ROLE ACCOUNTADMIN;
```

### **PASO 3: Ejecutar Script Completo**
1. **Abre este archivo**: `app_setup.sql`
2. **Selecciona TODO** el contenido (Ctrl+A)
3. **Copia** el contenido (Ctrl+C)
4. **En Snowsight**: 
   - Crea una nueva worksheet
   - Pega todo el contenido (Ctrl+V)
   - Ejecuta todo (Ctrl+Enter o "Run All")

---

## 📋 Lo que Ejecutará el Script

### ✅ **Configuración Inicial**
- Warehouse: `scno_wh`
- Rol: `scno_role` con permisos Cortex
- Base de datos: `supply_chain_network_optimization_db`

### ✅ **Datos Colombianos**
- **10 Fábricas**: Bogotá, Medellín, Cali, Barranquilla, etc.
- **25 Distribuidores**: Cobertura nacional completa
- **Coordenadas reales** de Colombia

### ✅ **Aplicación Streamlit**
- Interfaz completamente en español
- Claude 3.5 Sonnet para Cortex
- Generación de clientes 100% colombianos

---

## 🎯 Verificación Rápida

### **Después de ejecutar, verifica:**
```sql
-- 1. Verificar fábricas colombianas
SELECT city, state, country, production_capacity 
FROM supply_chain_network_optimization_db.entities.factory 
ORDER BY city;

-- 2. Verificar distribuidores colombianos  
SELECT city, state, country, throughput_capacity
FROM supply_chain_network_optimization_db.entities.distributor 
ORDER BY city;

-- 3. Verificar aplicación Streamlit
SHOW STREAMLITS IN SCHEMA supply_chain_network_optimization_db.streamlit;
```

### **Resultados Esperados:**
✅ 10 fábricas en ciudades colombianas  
✅ 25 distribuidores en departamentos colombianos  
✅ 1 aplicación Streamlit creada  

---

## 🌟 Acceder a la Aplicación

### **Una vez completado:**
1. **Cambiar rol**: `USE ROLE SCNO_ROLE;`
2. **Navegar**: Proyectos → Streamlit
3. **Abrir**: `SUPPLY_CHAIN_NETWORK_OPTIMIZATION`

### **Funcionalidades Corregidas:**
✅ Página "Preparación de Datos" - tabla con cabeceras correctas  
✅ Página "Resultados del Modelo" - mapas solo con puntos colombianos  
✅ Página "Enriquecimiento Cortex" - sin errores KeyError  
✅ Claude 3.5 Sonnet para mejores respuestas de IA  

---

## 🛠️ Solución de Problemas

### **Si hay errores de permisos:**
```sql
USE ROLE ACCOUNTADMIN;
-- Luego ejecutar el script
```

### **Para limpiar y empezar de nuevo:**
```sql
USE ROLE ACCOUNTADMIN;
DROP DATABASE IF EXISTS supply_chain_network_optimization_db CASCADE;
DROP ROLE IF EXISTS scno_role;
DROP WAREHOUSE IF EXISTS scno_wh;
-- Luego ejecutar app_setup.sql nuevamente
```

---

## ✅ ¡Listo!

Una vez ejecutado el script, tendrás un modelo de optimización de cadena de suministro completamente funcional, adaptado a Colombia, con interfaz en español y Claude 3.5 Sonnet para IA de última generación.

🇨🇴 **¡Disfruta optimizando cadenas de suministro colombianas!** 🚀
