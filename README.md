# Optimización de Red de Cadena de Suministro

<a href="https://emerging-solutions-toolbox.streamlit.app/">
    <img src="https://github.com/user-attachments/assets/aa206d11-1d86-4f32-8a6d-49fe9715b098" alt="image" width="150" align="right";">
</a>

El Modelo de Optimización de Red de Cadena de Suministro utiliza [Programación Lineal](https://en.wikipedia.org/wiki/Linear_programming), también llamada optimización lineal o programación con restricciones.

La programación lineal usa un sistema de desigualdades para definir un espacio matemático regional factible, y un 'solver' que recorre ese espacio ajustando una serie de variables de decisión, encontrando eficientemente el conjunto más óptimo de decisiones dadas las restricciones para cumplir con una función objetivo establecida.

También es posible introducir variables de decisión basadas en enteros, lo que transforma el problema de un *programa lineal* a un *programa entero mixto*, pero la mecánica es fundamentalmente la misma.

La **función objetivo** define la meta - maximizar o minimizar un valor, como la ganancia o los costos.
Las **variables de decisión** son un conjunto de decisiones - los valores que el solver puede cambiar para impactar el valor objetivo.
Las **restricciones** definen las realidades del negocio - como enviar solo hasta una capacidad establecida.

Estamos utilizando la biblioteca PuLP, que nos permite definir un programa lineal usando Python y usar virtualmente cualquier solver que queramos. Estamos usando el [solver CBC](https://github.com/coin-or/Cbc) incluido en PuLP para nuestros modelos.

## Aviso de Soporte

Todo el código de muestra se proporciona únicamente con fines de referencia. Tenga en cuenta que este código se proporciona `tal como está` y sin garantía. Snowflake no ofrecerá ningún soporte para el uso del código de muestra. El propósito del código es proporcionar a los clientes acceso fácil a ideas innovadoras que se han construido para acelerar la adopción de características clave de Snowflake por parte de los clientes. Ciertamente buscamos comentarios de los clientes sobre estas soluciones y estaremos actualizando características, corrigiendo errores y lanzando nuevas soluciones de forma regular.

Copyright (c) 2025 Snowflake Inc. Todos los Derechos Reservados.

## Problema(s) a Resolver

Para nuestro modelo, somos una empresa grande con una gran red de fábricas, distribuidores y clientes. Queremos entregar productos de la manera más económica posible.

Cada fábrica tiene su propio conjunto de capacidades de producción, costos de producción y costos de flete. Cada Distribuidor tiene su propio conjunto de capacidades de rendimiento, costos de rendimiento y costos de flete. Cada cliente tiene un conjunto de demanda. El flete es un producto cruzado entre cada fábrica y distribuidor, y cada distribuidor y cliente. Estamos asumiendo que las Fábricas no pueden enviar directamente a los Clientes en este modelo - esto emula envíos a granel que probablemente salgan de las fábricas.

Dado que este es un modelo de costos, estamos asumiendo que toda la demanda del cliente debe ser satisfecha - así que no hay decisión de no enviar a un cliente, independientemente del costo.

Estamos resolviendo el problema con tres objetivos diferentes... emulando un "gatear, caminar, correr" para alcanzar una planificación de cumplimiento verdaderamente óptima. Los problemas son:

- **Minimizar Distancia** (Gatear) - Emulando un presente bastante ingenuo, donde solo se considera la distancia. Así es típicamente como se dividirá la planificación si no se trata como un sistema.
- **Minimizar Flete** (Caminar) - Emulando una organización con capacidad de análisis de flete, donde solo se considera el costo del flete. Así es típicamente como sucede la planificación en organizaciones con una función de planificación de flete.
- **Minimizar Cumplimiento Total** (Correr) - Emulando una capacidad de análisis de red completamente realizada, donde se consideran todos los costos de producción/rendimiento/flete. Esto es lo que sucede cuando se entiende y considera todo el negocio durante la planificación.

## Conclusiones

**Minimizar Cumplimiento Total** presenta el plan de cumplimiento más óptimo y económico, incluso si algunas decisiones individuales parecen no tener sentido en aislamiento. Cualquier desviación del plan incurrirá en costos adicionales. Esto *no* significa que este modelo sea completamente factible en la realidad, pero cualquier intento de hacer coincidir el negocio con él mejorará los costos.

Este también es un modelo de optimización de costos... asume que tienes que enviar a cada cliente su demanda, incluso si es un envío que genera pérdidas. Para convertirlo a "¿a qué clientes debería enviar?", ajustarías la función objetivo a un modelo de maximización de ganancias, y necesitarías vincular ingresos a él - primero agregando precio a cada cliente actual, y agregando cada cliente potencial que conozcas y estimaciones de su volumen/precio/costos de flete.

## Cortex

Además de tomar un conjunto de decisiones óptimas para más de 25k decisiones, también podemos aprovechar la funcionalidad del Modelo de Lenguaje Grande (LLM) Cortex de Snowflake. Esto nos da una buena vista de cómo podemos aprovechar la IA para enriquecer nuestros datos de cadena de suministro en un esfuerzo por entender el contexto más amplio de la cadena de suministro. Nuestros ejemplos agregan algunos campos nuevos que se generan a través de prompts.

**Nota** - La IA es una ciencia imprecisa que está mejorando cada día, por lo que es importante verificar los resultados para la razonabilidad y entender que los valores son aproximados. Es perfecto para agregar algo de sabor adicional a nuestros datos, pero no es ideal para analizar nuestros resultados del modelo.

## Instrucciones

1. Ejecutar app_setup.sql como ACCOUNTADMIN en tu cuenta de Snowflake
2. En Snowsight, mantén tu rol como ACCOUNTADMIN, navega a Proyectos en la barra lateral izquierda, y selecciona Streamlit
3. Selecciona SUPPLY_CHAIN_NETWORK_OPTIMIZATION en tu lista de Aplicaciones Streamlit
4. Sigue las instrucciones dentro de la aplicación

## Etiquetado

Por favor consulta `TAGGING.md` para detalles sobre comentarios de objetos.