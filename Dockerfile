FROM debezium/connect:3.0.0.Final
RUN curl -fsSL https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/12.4.2.jre11/mssql-jdbc-12.4.2.jre11.jar -o /kafka/connect/mssql-jdbc.jar
