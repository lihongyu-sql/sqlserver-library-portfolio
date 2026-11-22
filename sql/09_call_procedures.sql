USE LibraryPractice;

-- 借书：读者 R005 借出条码 B011
EXEC dbo.usp_BorrowBook
    @ReaderNo = 'R005',
    @Barcode = 'B011',
    @LoanDays = 30;

-- 确认当前借阅视图出现 B011
SELECT *
FROM dbo.vw_ActiveLoans
WHERE Barcode = 'B011';

-- 还书：归还条码 B011
EXEC dbo.usp_ReturnBook
    @Barcode = 'B011';

-- 确认 B011 已恢复可借，且不再出现在在借视图中
SELECT
    Barcode,
    CopyStatus
FROM dbo.BookCopies
WHERE Barcode = 'B011';

SELECT *
FROM dbo.vw_ActiveLoans
WHERE Barcode = 'B011';

