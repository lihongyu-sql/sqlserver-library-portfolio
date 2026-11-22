USE LibraryPractice;

-- 同一本实体书只能存在一条未归还记录。
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.BorrowRecords')
      AND name = N'UX_BorrowRecords_ActiveCopy'
)
BEGIN
    CREATE UNIQUE INDEX UX_BorrowRecords_ActiveCopy
        ON dbo.BorrowRecords(CopyId)
        WHERE ReturnDate IS NULL;
END;

-- 按读者查询借阅历史，并覆盖常用返回字段。
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.BorrowRecords')
      AND name = N'IX_BorrowRecords_Reader_Date'
)
BEGIN
    CREATE INDEX IX_BorrowRecords_Reader_Date
        ON dbo.BorrowRecords(ReaderId, BorrowDate DESC)
        INCLUDE (CopyId, DueDate, ReturnDate, FineAmount);
END;

-- 按图书查询库存状态。
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.BookCopies')
      AND name = N'IX_BookCopies_Book_Status'
)
BEGIN
    CREATE INDEX IX_BookCopies_Book_Status
        ON dbo.BookCopies(BookId, CopyStatus)
        INCLUDE (Barcode);
END;

SELECT
    i.name AS IndexName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.is_unique AS IsUnique,
    i.has_filter AS IsFiltered
FROM sys.indexes AS i
WHERE i.object_id IN
(
    OBJECT_ID(N'dbo.BorrowRecords'),
    OBJECT_ID(N'dbo.BookCopies')
)
  AND i.name IS NOT NULL
ORDER BY TableName, IndexName;

