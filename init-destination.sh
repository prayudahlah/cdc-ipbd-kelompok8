#!/bin/bash
/opt/mssql/bin/sqlservr &

# Tunggu SQL Server siap
sleep 20

/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -C -Q "CREATE DATABASE kuliah;"

wait
