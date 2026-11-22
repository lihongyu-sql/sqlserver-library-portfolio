USE master;

IF DB_ID(N'LibraryPractice') IS NULL
BEGIN
    CREATE DATABASE LibraryPractice;
END;

SELECT
    name,
    state_desc
FROM sys.databases
WHERE name = N'LibraryPractice';

