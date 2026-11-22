USE master;

SELECT
    @@VERSION AS SqlServerVersion,
    DB_NAME() AS CurrentDatabase,
    SUSER_SNAME() AS LoginName;

