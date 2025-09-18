import streamlit as st
from snowflake.snowpark.session import Session
import os
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

# Carga la clave privada
pkb = ""

if st.secrets["local_key_path"] != "":
    with open(st.secrets["local_key_path"], "rb") as key:
        p_key = serialization.load_pem_private_key(
            key.read(),
            password=os.environ['PRIVATE_KEY_PASSPHRASE'].encode(),
            backend=default_backend()
        )

    # Almacena la clave pública
    pkb = p_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption())


# Crear Sesión de Snowpark
def init_snowpark_session(account):
    connection_parameters = dict(st.secrets[account])

    # Agregar clave pública, si está presente
    if pkb != "":
        connection_parameters["private_key"] = pkb

    return Session.builder.configs(connection_parameters).create()
