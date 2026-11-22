USE LibraryPractice;

-- 1. 读者借阅概览：连接、分组、CASE WHEN、HAVING
SELECT
    r.ReaderNo,
    r.ReaderName,
    r.ReaderType,
    COUNT(br.BorrowId) AS TotalBorrowCount,
    SUM(
        CASE
            WHEN br.BorrowId IS NOT NULL
             AND br.ReturnDate IS NULL
                THEN 1
            ELSE 0
        END
    ) AS ActiveBorrowCount,
    COALESCE(SUM(br.FineAmount), 0) AS TotalFine
FROM dbo.Readers AS r
LEFT JOIN dbo.BorrowRecords AS br
    ON br.ReaderId = r.ReaderId
GROUP BY r.ReaderId, r.ReaderNo, r.ReaderName, r.ReaderType
ORDER BY TotalBorrowCount DESC, r.ReaderNo;

-- 2. 逾期记录：没有归还且已超过到期日
SELECT
    r.ReaderNo,
    r.ReaderName,
    b.Title,
    c.Barcode,
    br.DueDate,
    DATEDIFF(DAY, br.DueDate, GETDATE()) AS OverdueDays,
    CAST(DATEDIFF(DAY, br.DueDate, GETDATE()) * 0.50 AS DECIMAL(10, 2)) AS EstimatedFine
FROM dbo.BorrowRecords AS br
INNER JOIN dbo.Readers AS r
    ON r.ReaderId = br.ReaderId
INNER JOIN dbo.BookCopies AS c
    ON c.CopyId = br.CopyId
INNER JOIN dbo.Books AS b
    ON b.BookId = c.BookId
WHERE br.ReturnDate IS NULL
  AND br.DueDate < GETDATE()
ORDER BY OverdueDays DESC, r.ReaderNo;

-- 3. 使用 NOT EXISTS 查询从未借过书的读者
SELECT
    r.ReaderNo,
    r.ReaderName
FROM dbo.Readers AS r
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.BorrowRecords AS br
    WHERE br.ReaderId = r.ReaderId
);

-- 4. 按借阅次数给图书分类排名
WITH CategoryBorrows AS
(
    SELECT
        b.Category,
        COUNT(br.BorrowId) AS BorrowCount
    FROM dbo.Books AS b
    INNER JOIN dbo.BookCopies AS c
        ON c.BookId = b.BookId
    INNER JOIN dbo.BorrowRecords AS br
        ON br.CopyId = c.CopyId
    GROUP BY b.Category
)
SELECT
    Category,
    BorrowCount,
    RANK() OVER (ORDER BY BorrowCount DESC) AS CategoryRank
FROM CategoryBorrows
ORDER BY CategoryRank, Category;

-- 5. 为每个分类找出借阅次数最高的图书
WITH BookBorrows AS
(
    SELECT
        b.Category,
        b.Title,
        COUNT(br.BorrowId) AS BorrowCount,
        ROW_NUMBER() OVER
        (
            PARTITION BY b.Category
            ORDER BY COUNT(br.BorrowId) DESC, b.Title
        ) AS RowNum
    FROM dbo.Books AS b
    INNER JOIN dbo.BookCopies AS c
        ON c.BookId = b.BookId
    INNER JOIN dbo.BorrowRecords AS br
        ON br.CopyId = c.CopyId
    GROUP BY b.Category, b.BookId, b.Title
)
SELECT
    Category,
    Title,
    BorrowCount
FROM BookBorrows
WHERE RowNum = 1
ORDER BY Category;

-- 6. 在查询结果中计算每位读者的累计借阅次数
WITH DailyBorrows AS
(
    SELECT
        ReaderId,
        CAST(BorrowDate AS date) AS BorrowDay,
        COUNT(*) AS DailyCount
    FROM dbo.BorrowRecords
    GROUP BY ReaderId, CAST(BorrowDate AS date)
)
SELECT
    r.ReaderNo,
    r.ReaderName,
    db.BorrowDay,
    db.DailyCount,
    SUM(db.DailyCount) OVER
    (
        PARTITION BY db.ReaderId
        ORDER BY db.BorrowDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningBorrowCount
FROM DailyBorrows AS db
INNER JOIN dbo.Readers AS r
    ON r.ReaderId = db.ReaderId
ORDER BY r.ReaderNo, db.BorrowDay;

