USE LibraryPractice;

SET NOCOUNT ON;

SELECT
    COUNT(*) AS TableCount
FROM sys.tables
WHERE schema_id = SCHEMA_ID(N'dbo');

SELECT
    (SELECT COUNT(*) FROM dbo.Readers) AS ReaderCount,
    (SELECT COUNT(*) FROM dbo.Books) AS BookCount,
    (SELECT COUNT(*) FROM dbo.BookCopies) AS CopyCount,
    (SELECT COUNT(*) FROM dbo.BorrowRecords) AS BorrowRecordCount;

SELECT
    CASE
        WHEN COUNT(*) = 0 THEN N'通过：不存在重复在借记录'
        ELSE N'失败：存在同一实体书的重复在借记录'
    END AS ActiveBorrowCheck
FROM
(
    SELECT CopyId
    FROM dbo.BorrowRecords
    WHERE ReturnDate IS NULL
    GROUP BY CopyId
    HAVING COUNT(*) > 1
) AS DuplicateActiveCopies;

SELECT
    COUNT(*) AS ActiveLoanCount,
    SUM(CASE WHEN IsOverdue = 1 THEN 1 ELSE 0 END) AS OverdueLoanCount
FROM dbo.vw_ActiveLoans;

SELECT
    b.Title,
    SUM(CASE WHEN c.CopyStatus = 'AVAILABLE' THEN 1 ELSE 0 END) AS AvailableCopies,
    SUM(CASE WHEN c.CopyStatus = 'BORROWED' THEN 1 ELSE 0 END) AS BorrowedCopies
FROM dbo.Books AS b
INNER JOIN dbo.BookCopies AS c
    ON c.BookId = b.BookId
GROUP BY b.BookId, b.Title
ORDER BY BorrowedCopies DESC, b.Title;

SELECT
    name AS ProcedureName
FROM sys.procedures
WHERE schema_id = SCHEMA_ID(N'dbo')
ORDER BY name;

