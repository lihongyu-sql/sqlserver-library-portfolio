USE LibraryPractice;

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

INSERT INTO dbo.Readers (ReaderNo, ReaderName, ReaderType, Phone)
VALUES
    ('R001', N'李明',   'STUDENT', '13800000001'),
    ('R002', N'王芳',   'STUDENT', '13800000002'),
    ('R003', N'赵强',   'TEACHER', '13800000003'),
    ('R004', N'陈静',   'STUDENT', '13800000004'),
    ('R005', N'刘洋',   'TEACHER', '13800000005'),
    ('R006', N'孙悦',   'STUDENT', '13800000006');

INSERT INTO dbo.Books (ISBN, Title, Author, Category, Price, PublishedYear)
VALUES
    ('9787111000001', N'SQL Server 数据库基础', N'张明',     N'数据库', 69.00, 2022),
    ('9787111000002', N'数据库系统概论',       N'王珊',     N'数据库', 59.00, 2019),
    ('9787111000003', N'C# 程序设计',          N'李伟',     N'程序设计', 79.00, 2021),
    ('9787111000004', N'计算机网络',           N'谢希仁',   N'网络',   55.00, 2020),
    ('9787111000005', N'操作系统原理',         N'汤小丹',   N'系统',   65.00, 2018),
    ('9787111000006', N'数据结构',             N'严蔚敏',   N'程序设计', 49.00, 2017),
    ('9787111000007', N'软件工程导论',         N'张海藩',   N'软件工程', 52.00, 2020),
    ('9787111000008', N'网络安全基础',         N'刘建伟',   N'网络',   58.00, 2023);

INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B001', 'BORROWED' FROM dbo.Books WHERE ISBN = '9787111000001';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B002', 'BORROWED' FROM dbo.Books WHERE ISBN = '9787111000002';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B003', 'AVAILABLE' FROM dbo.Books WHERE ISBN = '9787111000002';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B004', 'BORROWED' FROM dbo.Books WHERE ISBN = '9787111000003';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B005', 'AVAILABLE' FROM dbo.Books WHERE ISBN = '9787111000004';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B006', 'BORROWED' FROM dbo.Books WHERE ISBN = '9787111000004';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B007', 'AVAILABLE' FROM dbo.Books WHERE ISBN = '9787111000005';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B008', 'AVAILABLE' FROM dbo.Books WHERE ISBN = '9787111000006';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B009', 'AVAILABLE' FROM dbo.Books WHERE ISBN = '9787111000007';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B010', 'AVAILABLE' FROM dbo.Books WHERE ISBN = '9787111000008';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B011', 'AVAILABLE' FROM dbo.Books WHERE ISBN = '9787111000008';
INSERT INTO dbo.BookCopies (BookId, Barcode, CopyStatus)
SELECT BookId, 'B012', 'AVAILABLE' FROM dbo.Books WHERE ISBN = '9787111000001';

INSERT INTO dbo.BorrowRecords
    (CopyId, ReaderId, BorrowDate, DueDate, ReturnDate, FineAmount)
SELECT
    c.CopyId,
    r.ReaderId,
    DATEADD(DAY, -40, CAST(GETDATE() AS date)),
    DATEADD(DAY, -10, CAST(GETDATE() AS date)),
    NULL,
    0
FROM dbo.BookCopies AS c
CROSS JOIN dbo.Readers AS r
WHERE c.Barcode = 'B001' AND r.ReaderNo = 'R001';

INSERT INTO dbo.BorrowRecords
    (CopyId, ReaderId, BorrowDate, DueDate, ReturnDate, FineAmount)
SELECT
    c.CopyId,
    r.ReaderId,
    DATEADD(DAY, -35, CAST(GETDATE() AS date)),
    DATEADD(DAY, -5, CAST(GETDATE() AS date)),
    NULL,
    0
FROM dbo.BookCopies AS c
CROSS JOIN dbo.Readers AS r
WHERE c.Barcode = 'B002' AND r.ReaderNo = 'R002';

INSERT INTO dbo.BorrowRecords
    (CopyId, ReaderId, BorrowDate, DueDate, ReturnDate, FineAmount)
SELECT
    c.CopyId,
    r.ReaderId,
    DATEADD(DAY, -60, CAST(GETDATE() AS date)),
    DATEADD(DAY, -30, CAST(GETDATE() AS date)),
    DATEADD(DAY, -25, CAST(GETDATE() AS date)),
    2.50
FROM dbo.BookCopies AS c
CROSS JOIN dbo.Readers AS r
WHERE c.Barcode = 'B003' AND r.ReaderNo = 'R001';

INSERT INTO dbo.BorrowRecords
    (CopyId, ReaderId, BorrowDate, DueDate, ReturnDate, FineAmount)
SELECT
    c.CopyId,
    r.ReaderId,
    DATEADD(DAY, -10, CAST(GETDATE() AS date)),
    DATEADD(DAY, 20, CAST(GETDATE() AS date)),
    NULL,
    0
FROM dbo.BookCopies AS c
CROSS JOIN dbo.Readers AS r
WHERE c.Barcode = 'B004' AND r.ReaderNo = 'R004';

INSERT INTO dbo.BorrowRecords
    (CopyId, ReaderId, BorrowDate, DueDate, ReturnDate, FineAmount)
SELECT
    c.CopyId,
    r.ReaderId,
    DATEADD(DAY, -90, CAST(GETDATE() AS date)),
    DATEADD(DAY, -60, CAST(GETDATE() AS date)),
    DATEADD(DAY, -65, CAST(GETDATE() AS date)),
    0
FROM dbo.BookCopies AS c
CROSS JOIN dbo.Readers AS r
WHERE c.Barcode = 'B008' AND r.ReaderNo = 'R002';

INSERT INTO dbo.BorrowRecords
    (CopyId, ReaderId, BorrowDate, DueDate, ReturnDate, FineAmount)
SELECT
    c.CopyId,
    r.ReaderId,
    DATEADD(DAY, -45, CAST(GETDATE() AS date)),
    DATEADD(DAY, -15, CAST(GETDATE() AS date)),
    NULL,
    0
FROM dbo.BookCopies AS c
CROSS JOIN dbo.Readers AS r
WHERE c.Barcode = 'B006' AND r.ReaderNo = 'R003';

COMMIT TRANSACTION;

SELECT
    (SELECT COUNT(*) FROM dbo.Readers) AS ReaderCount,
    (SELECT COUNT(*) FROM dbo.Books) AS BookCount,
    (SELECT COUNT(*) FROM dbo.BookCopies) AS CopyCount,
    (SELECT COUNT(*) FROM dbo.BorrowRecords) AS BorrowRecordCount;

