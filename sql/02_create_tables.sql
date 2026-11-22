USE LibraryPractice;

DROP TABLE IF EXISTS dbo.BorrowRecords;
DROP TABLE IF EXISTS dbo.BookCopies;
DROP TABLE IF EXISTS dbo.Books;
DROP TABLE IF EXISTS dbo.Readers;

CREATE TABLE dbo.Readers
(
    ReaderId       INT IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_Readers PRIMARY KEY,
    ReaderNo       VARCHAR(20) NOT NULL
        CONSTRAINT UQ_Readers_ReaderNo UNIQUE,
    ReaderName     NVARCHAR(50) NOT NULL,
    ReaderType     VARCHAR(20) NOT NULL
        CONSTRAINT CK_Readers_ReaderType CHECK (ReaderType IN ('STUDENT', 'TEACHER')),
    Phone          VARCHAR(20) NULL,
    CreatedAt      DATETIME2(0) NOT NULL
        CONSTRAINT DF_Readers_CreatedAt DEFAULT SYSDATETIME()
);

CREATE TABLE dbo.Books
(
    BookId         INT IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_Books PRIMARY KEY,
    ISBN           VARCHAR(20) NOT NULL
        CONSTRAINT UQ_Books_ISBN UNIQUE,
    Title          NVARCHAR(200) NOT NULL,
    Author         NVARCHAR(100) NOT NULL,
    Category       NVARCHAR(50) NOT NULL,
    Price          DECIMAL(10, 2) NOT NULL
        CONSTRAINT CK_Books_Price CHECK (Price > 0),
    PublishedYear  SMALLINT NULL,
    CreatedAt      DATETIME2(0) NOT NULL
        CONSTRAINT DF_Books_CreatedAt DEFAULT SYSDATETIME()
);

CREATE TABLE dbo.BookCopies
(
    CopyId         INT IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_BookCopies PRIMARY KEY,
    BookId         INT NOT NULL,
    Barcode        VARCHAR(30) NOT NULL
        CONSTRAINT UQ_BookCopies_Barcode UNIQUE,
    CopyStatus     VARCHAR(20) NOT NULL
        CONSTRAINT DF_BookCopies_CopyStatus DEFAULT 'AVAILABLE'
        CONSTRAINT CK_BookCopies_CopyStatus CHECK (CopyStatus IN ('AVAILABLE', 'BORROWED', 'LOST')),
    AddedAt        DATETIME2(0) NOT NULL
        CONSTRAINT DF_BookCopies_AddedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_BookCopies_Books
        FOREIGN KEY (BookId) REFERENCES dbo.Books(BookId)
);

CREATE TABLE dbo.BorrowRecords
(
    BorrowId       BIGINT IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_BorrowRecords PRIMARY KEY,
    CopyId         INT NOT NULL,
    ReaderId       INT NOT NULL,
    BorrowDate     DATETIME2(0) NOT NULL,
    DueDate        DATETIME2(0) NOT NULL,
    ReturnDate     DATETIME2(0) NULL,
    FineAmount     DECIMAL(10, 2) NOT NULL
        CONSTRAINT DF_BorrowRecords_FineAmount DEFAULT 0,
    CreatedAt      DATETIME2(0) NOT NULL
        CONSTRAINT DF_BorrowRecords_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT CK_BorrowRecords_DateRange CHECK (DueDate > BorrowDate),
    CONSTRAINT CK_BorrowRecords_FineAmount CHECK (FineAmount >= 0),
    CONSTRAINT FK_BorrowRecords_BookCopies
        FOREIGN KEY (CopyId) REFERENCES dbo.BookCopies(CopyId),
    CONSTRAINT FK_BorrowRecords_Readers
        FOREIGN KEY (ReaderId) REFERENCES dbo.Readers(ReaderId)
);

SELECT
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
WHERE s.name = N'dbo'
ORDER BY t.name;

