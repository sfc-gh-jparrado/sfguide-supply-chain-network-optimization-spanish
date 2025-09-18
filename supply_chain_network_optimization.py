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


# Establece la página basada en el nombre de la página
def set_page(page: str):
    st.session_state.page = page


class OptimizationModel:
    """
    Una clase utilizada para representar un modelo de optimización de red de cadena de suministro. Un modelo de optimización
    maximiza/minimiza matemáticamente una función objetivo basada en variables de decisión y un conjunto dado de restricciones.

    Para usar:
        - Instanciar la clase
        - Ejecutar el método prepare_data para configurar los datos del modelo
        - Ejecutar el método solve, pasando uno de los nombres de problema soportados
        - Hay un método solve_sample para ejecutar un modelo autocontenido

    Cualquier modelo es específico para las entidades, relaciones, restricciones y objetivo de un negocio particular. Este es un
    modelo de demostración que describe un escenario típico de cadena de suministro.
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
        if st.button(label="Volver al Inicio", help="Advertencia: ¡Los cambios no guardados se perderán!"):
            set_page('Bienvenida')
            st.rerun()


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


class WelcomePage(Page):
    def __init__(self):
        self.name = "Bienvenida"

    def print_page(self):
        # Configurar página principal
        col1, col2 = st.columns((6, 1))
        col1.title("Optimización de Red de Cadena de Suministro 🐻‍❄️")

        # Página de bienvenida
        st.subheader("Bienvenido ❄️")

        st.write('''El Modelo de Optimización de Red de Cadena de Suministro utiliza [Programación Lineal](
        https://en.wikipedia.org/wiki/Linear_programming), también llamada optimización lineal o programación con restricciones.''')

        st.write('''La programación lineal usa un sistema de desigualdades para definir un espacio matemático regional factible, y un
        'solver' que recorre ese espacio ajustando una serie de variables de decisión, encontrando eficientemente el conjunto más óptimo
        de decisiones dadas las restricciones para cumplir con una función objetivo establecida.''')

        st.write('''También es posible introducir variables de decisión basadas en enteros, lo que transforma el problema de un programa lineal a un programa entero mixto, pero la mecánica es
        fundamentalmente la misma.''')

        st.write("La función objetivo define la meta - maximizar o minimizar un valor, como la ganancia o los costos.")
        st.write("Las variables de decisión son un conjunto de decisiones - los valores que el solver puede cambiar para impactar el "
                 "valor objetivo.")
        st.write(
            "Las restricciones definen las realidades del negocio - como enviar solo hasta una capacidad establecida.")

        st.write("Estamos utilizando la biblioteca PuLP, que nos permite definir un programa lineal y usar virtualmente cualquier "
                 "solver que queramos. Estamos usando el [solver CBC](https://github.com/coin-or/Cbc) gratuito por defecto de PuLP para nuestros "
                 "modelos.")

        with st.expander("Recursos Adicionales", expanded=True):
            st.write("¿Interesado en [Programación de Optimización usando PuLP](https://coin-or.github.io/pulp/)?")

    def print_sidebar(self):
        set_default_sidebar()


pages = [WelcomePage()]


def main():
    for page in pages:
        if page.name == st.session_state.page:
            page.print_page()
            page.print_sidebar()


main()
