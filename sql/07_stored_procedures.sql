USE LibraryPractice;
GO

CREATE OR ALTER PROCEDURE dbo.usp_BorrowBook
    @ReaderNo VARCHAR(20),
    @Barcode VARCHAR(30),
    @LoanDays INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @LoanDays <= 0
        THROW 50001, N'借阅天数必须大于 0。', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @ReaderId INT,
            @CopyId INT,
            @CopyStatus VARCHAR(20),
            @BorrowDate DATETIME2(0) = SYSDATETIME(),
            @DueDate DATETIME2(0) = DATEADD(DAY, @LoanDays, SYSDATETIME());

        SELECT @ReaderId = ReaderId
        FROM dbo.Readers WITH (UPDLOCK, HOLDLOCK)
        WHERE ReaderNo = @ReaderNo;

        IF @ReaderId IS NULL
            THROW 50002, N'读者编号不存在。', 1;

        SELECT
            @CopyId = CopyId,
            @CopyStatus = CopyStatus
        FROM dbo.BookCopies WITH (UPDLOCK, HOLDLOCK)
        WHERE Barcode = @Barcode;

        IF @CopyId IS NULL
            THROW 50003, N'图书条码不存在。', 1;

        IF @CopyStatus <> 'AVAILABLE'
            THROW 50004, N'当前实体书不可借。', 1;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.BorrowRecords
            WHERE CopyId = @CopyId
              AND ReturnDate IS NULL
        )
            THROW 50005, N'当前实体书存在未归还的借阅记录。', 1;

        INSERT INTO dbo.BorrowRecords
            (CopyId, ReaderId, BorrowDate, DueDate, ReturnDate, FineAmount)
        VALUES
            (@CopyId, @ReaderId, @BorrowDate, @DueDate, NULL, 0);

        UPDATE dbo.BookCopies
        SET CopyStatus = 'BORROWED'
        WHERE CopyId = @CopyId;

        COMMIT TRANSACTION;

        SELECT
            SCOPE_IDENTITY() AS BorrowId,
            @ReaderNo AS ReaderNo,
            @Barcode AS Barcode,
            @BorrowDate AS BorrowDate,
            @DueDate AS DueDate,
            N'借阅成功' AS ResultMessage;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ReturnBook
    @Barcode VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @BorrowId BIGINT,
            @CopyId INT,
            @DueDate DATETIME2(0),
            @ReturnDate DATETIME2(0) = SYSDATETIME(),
            @OverdueDays INT = 0,
            @FineAmount DECIMAL(10, 2) = 0;

        SELECT TOP (1)
            @BorrowId = br.BorrowId,
            @CopyId = br.CopyId,
            @DueDate = br.DueDate
        FROM dbo.BorrowRecords AS br WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN dbo.BookCopies AS c
            ON c.CopyId = br.CopyId
        WHERE c.Barcode = @Barcode
          AND br.ReturnDate IS NULL
        ORDER BY br.BorrowDate DESC;

        IF @BorrowId IS NULL
            THROW 50101, N'未找到该实体书的未归还记录。', 1;

        IF @ReturnDate > @DueDate
            SET @OverdueDays = DATEDIFF(DAY, @DueDate, @ReturnDate);

        SET @FineAmount = CAST(@OverdueDays * 0.50 AS DECIMAL(10, 2));

        UPDATE dbo.BorrowRecords
        SET
            ReturnDate = @ReturnDate,
            FineAmount = @FineAmount
        WHERE BorrowId = @BorrowId;

        UPDATE dbo.BookCopies
        SET CopyStatus = 'AVAILABLE'
        WHERE CopyId = @CopyId;

        COMMIT TRANSACTION;

        SELECT
            @BorrowId AS BorrowId,
            @Barcode AS Barcode,
            @ReturnDate AS ReturnDate,
            @OverdueDays AS OverdueDays,
            @FineAmount AS FineAmount,
            N'归还成功' AS ResultMessage;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;

