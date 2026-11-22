USE LibraryPractice;

-- 1. 查询全部图书，按分类和书名排序
SELECT
    BookId,
    ISBN,
    Title,
    Author,
    Category,
    Price
FROM dbo.Books
ORDER BY Category, Title;

-- 2. 查询数据库分类且价格不低于 60 元的图书
SELECT
    Title,
    Author,
    Price
FROM dbo.Books
WHERE Category = N'数据库'
  AND Price >= 60
ORDER BY Price DESC;

-- 3. 按分类统计图书数量、平均价格和价格区间
SELECT
    Category,
    COUNT(*) AS BookCount,
    CAST(AVG(Price) AS DECIMAL(10, 2)) AS AveragePrice,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice
FROM dbo.Books
GROUP BY Category
ORDER BY BookCount DESC, Category;

-- 4. 只保留图书数量大于等于 2 的分类
SELECT
    Category,
    COUNT(*) AS BookCount
FROM dbo.Books
GROUP BY Category
HAVING COUNT(*) >= 2
ORDER BY BookCount DESC;

-- 5. 查询学生读者
SELECT
    ReaderNo,
    ReaderName,
    Phone
FROM dbo.Readers
WHERE ReaderType = 'STUDENT'
ORDER BY ReaderNo;

-- 6. 查看当前在借记录
SELECT
    br.BorrowId,
    r.ReaderNo,
    r.ReaderName,
    b.Title,
    c.Barcode,
    br.BorrowDate,
    br.DueDate
FROM dbo.BorrowRecords AS br
INNER JOIN dbo.Readers AS r
    ON r.ReaderId = br.ReaderId
INNER JOIN dbo.BookCopies AS c
    ON c.CopyId = br.CopyId
INNER JOIN dbo.Books AS b
    ON b.BookId = c.BookId
WHERE br.ReturnDate IS NULL
ORDER BY br.DueDate, br.BorrowId;

-- 7. 统计每种图书的实体副本数量
SELECT
    b.Title,
    COUNT(c.CopyId) AS CopyCount,
    SUM(CASE WHEN c.CopyStatus = 'AVAILABLE' THEN 1 ELSE 0 END) AS AvailableCount,
    SUM(CASE WHEN c.CopyStatus = 'BORROWED' THEN 1 ELSE 0 END) AS BorrowedCount
FROM dbo.Books AS b
LEFT JOIN dbo.BookCopies AS c
    ON c.BookId = b.BookId
GROUP BY b.BookId, b.Title
ORDER BY BorrowedCount DESC, b.Title;

-- 8. 查询书名或作者包含“数据”的图书
SELECT
    Title,
    Author,
    Category
FROM dbo.Books
WHERE Title LIKE N'%数据%'
   OR Author LIKE N'%数据%';

