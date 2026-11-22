USE LibraryPractice;
GO

CREATE OR ALTER VIEW dbo.vw_ActiveLoans
AS
SELECT
    br.BorrowId,
    r.ReaderNo,
    r.ReaderName,
    r.ReaderType,
    b.Title,
    b.Category,
    c.Barcode,
    br.BorrowDate,
    br.DueDate,
    CASE
        WHEN br.DueDate < GETDATE() THEN 1
        ELSE 0
    END AS IsOverdue,
    CASE
        WHEN br.DueDate < GETDATE()
            THEN DATEDIFF(DAY, br.DueDate, GETDATE())
        ELSE 0
    END AS OverdueDays
FROM dbo.BorrowRecords AS br
INNER JOIN dbo.Readers AS r
    ON r.ReaderId = br.ReaderId
INNER JOIN dbo.BookCopies AS c
    ON c.CopyId = br.CopyId
INNER JOIN dbo.Books AS b
    ON b.BookId = c.BookId
WHERE br.ReturnDate IS NULL;
GO

CREATE OR ALTER VIEW dbo.vw_BookInventory
AS
SELECT
    b.BookId,
    b.ISBN,
    b.Title,
    b.Category,
    COUNT(c.CopyId) AS TotalCopies,
    SUM(CASE WHEN c.CopyStatus = 'AVAILABLE' THEN 1 ELSE 0 END) AS AvailableCopies,
    SUM(CASE WHEN c.CopyStatus = 'BORROWED' THEN 1 ELSE 0 END) AS BorrowedCopies,
    SUM(CASE WHEN c.CopyStatus = 'LOST' THEN 1 ELSE 0 END) AS LostCopies
FROM dbo.Books AS b
LEFT JOIN dbo.BookCopies AS c
    ON c.BookId = b.BookId
GROUP BY b.BookId, b.ISBN, b.Title, b.Category;
GO

SELECT * FROM dbo.vw_ActiveLoans ORDER BY DueDate;
SELECT * FROM dbo.vw_BookInventory ORDER BY BorrowedCopies DESC, Title;

