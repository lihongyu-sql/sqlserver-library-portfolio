USE LibraryPractice;

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

UPDATE dbo.Readers
SET Phone = '13999999999'
WHERE ReaderNo = 'R001';

SELECT
    ReaderNo,
    ReaderName,
    Phone,
    '事务内修改后' AS Stage
FROM dbo.Readers
WHERE ReaderNo = 'R001';

-- 练习事务时回滚，不保留本次修改。
ROLLBACK TRANSACTION;

SELECT
    ReaderNo,
    ReaderName,
    Phone,
    '回滚后' AS Stage
FROM dbo.Readers
WHERE ReaderNo = 'R001';

