IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Calendars] (
        [Eventid] bigint NOT NULL IDENTITY,
        [Title] nvarchar(max) NOT NULL,
        [Date] bigint NOT NULL,
        CONSTRAINT [PK_Calendars] PRIMARY KEY ([Eventid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [ClassCourses] (
        [Classcourseid] bigint NOT NULL IDENTITY,
        [Courseid] bigint NOT NULL,
        CONSTRAINT [PK_ClassCourses] PRIMARY KEY ([Classcourseid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Classes] (
        [Classid] bigint NOT NULL IDENTITY,
        [Name] nvarchar(max) NOT NULL,
        [Capacity] int NOT NULL,
        [Grade] nvarchar(max) NOT NULL,
        CONSTRAINT [PK_Classes] PRIMARY KEY ([Classid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Courses] (
        [Courseid] bigint NOT NULL IDENTITY,
        [Name] nvarchar(max) NOT NULL,
        [Finalexamdate] nvarchar(max) NULL,
        [Classtime] nvarchar(max) NULL,
        [Classid] bigint NULL,
        [Teacherid] bigint NULL,
        CONSTRAINT [PK_Courses] PRIMARY KEY ([Courseid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Equipment] (
        [Equipmentid] bigint NOT NULL IDENTITY,
        [Eqcode] nvarchar(max) NOT NULL,
        [Eqcatry] nvarchar(max) NULL,
        [Location] nvarchar(max) NULL,
        CONSTRAINT [PK_Equipment] PRIMARY KEY ([Equipmentid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Exams] (
        [Examid] bigint NOT NULL IDENTITY,
        [Title] nvarchar(max) NOT NULL,
        [Image] nvarchar(max) NULL,
        [Startdate] nvarchar(max) NULL,
        [Enddate] nvarchar(max) NULL,
        [Starttime] nvarchar(max) NULL,
        [Endtime] nvarchar(max) NULL,
        [Courseid] bigint NOT NULL,
        [Classid] bigint NULL,
        [Description] nvarchar(max) NULL,
        [Filename] nvarchar(max) NULL,
        CONSTRAINT [PK_Exams] PRIMARY KEY ([Examid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [ExamStuTeaches] (
        [Estid] bigint NOT NULL IDENTITY,
        [Score] int NULL,
        [Answerimage] nvarchar(max) NULL,
        [Examid] bigint NOT NULL,
        [Courseid] bigint NOT NULL,
        [Teacherid] bigint NOT NULL,
        [Date] bigint NULL,
        [Studentid] bigint NULL,
        [Description] nvarchar(max) NULL,
        [Filename] nvarchar(max) NULL,
        CONSTRAINT [PK_ExamStuTeaches] PRIMARY KEY ([Estid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Exercises] (
        [Exerciseid] bigint NOT NULL IDENTITY,
        [Title] nvarchar(max) NOT NULL,
        [Image] nvarchar(max) NULL,
        [Startdate] nvarchar(max) NULL,
        [Enddate] nvarchar(max) NULL,
        [Starttime] nvarchar(max) NULL,
        [Endtime] nvarchar(max) NULL,
        [Courseid] bigint NOT NULL,
        [Description] nvarchar(max) NULL,
        [Classid] bigint NULL,
        [Filename] nvarchar(max) NULL,
        CONSTRAINT [PK_Exercises] PRIMARY KEY ([Exerciseid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [ExerciseStuTeaches] (
        [Exstid] bigint NOT NULL IDENTITY,
        [Score] int NULL,
        [Answerimage] nvarchar(max) NULL,
        [Exerciseid] bigint NOT NULL,
        [Courseid] bigint NOT NULL,
        [Teacherid] bigint NOT NULL,
        [Studentid] bigint NULL,
        [Description] nvarchar(max) NULL,
        [Date] bigint NULL,
        [Filename] nvarchar(max) NULL,
        CONSTRAINT [PK_ExerciseStuTeaches] PRIMARY KEY ([Exstid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Managers] (
        [Assistantid] bigint NOT NULL IDENTITY,
        [Userid] bigint NOT NULL,
        [Name] nvarchar(max) NOT NULL,
        CONSTRAINT [PK_Managers] PRIMARY KEY ([Assistantid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [News] (
        [Newsid] bigint NOT NULL IDENTITY,
        [Title] nvarchar(max) NOT NULL,
        [Category] nvarchar(max) NOT NULL,
        [Startdate] nvarchar(max) NOT NULL,
        [Enddate] nvarchar(max) NOT NULL,
        [Description] nvarchar(max) NULL,
        [Image] nvarchar(max) NULL,
        CONSTRAINT [PK_News] PRIMARY KEY ([Newsid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Scores] (
        [Id] bigint NOT NULL IDENTITY,
        [ScoreValue] bigint NOT NULL,
        [Score_month] nvarchar(max) NOT NULL,
        [Classid] bigint NULL,
        [Name] nvarchar(max) NULL,
        [StuCode] nvarchar(max) NULL,
        [Courseid] bigint NULL,
        CONSTRAINT [PK_Scores] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Students] (
        [Studentid] bigint NOT NULL IDENTITY,
        [Name] nvarchar(max) NOT NULL,
        [Score] int NULL,
        [Address] nvarchar(max) NULL,
        [Birthdate] bigint NULL,
        [Registerdate] bigint NULL,
        [ParentNum1] nvarchar(max) NULL,
        [ParentNum2] nvarchar(max) NULL,
        [Debt] bigint NULL,
        [StuCode] nvarchar(max) NOT NULL,
        [UserID] bigint NULL,
        [Classeid] bigint NULL,
        [Score_month] nvarchar(max) NULL,
        CONSTRAINT [PK_Students] PRIMARY KEY ([Studentid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Teachers] (
        [Teacherid] bigint NOT NULL IDENTITY,
        [Name] nvarchar(max) NOT NULL,
        [Userid] bigint NULL,
        [Courseid] bigint NULL,
        CONSTRAINT [PK_Teachers] PRIMARY KEY ([Teacherid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    CREATE TABLE [Users] (
        [Userid] bigint NOT NULL IDENTITY,
        [Username] nvarchar(max) NOT NULL,
        [Password] nvarchar(max) NOT NULL,
        [Role] nvarchar(max) NOT NULL,
        CONSTRAINT [PK_Users] PRIMARY KEY ([Userid])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251101201844_InitialCreate_SMS'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251101201844_InitialCreate_SMS', N'9.0.10');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var sysname;
    SELECT @var = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Scores]') AND [c].[name] = N'Name');
    IF @var IS NOT NULL EXEC(N'ALTER TABLE [Scores] DROP CONSTRAINT [' + @var + '];');
    ALTER TABLE [Scores] DROP COLUMN [Name];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var1 sysname;
    SELECT @var1 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exercises]') AND [c].[name] = N'Filename');
    IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Exercises] DROP CONSTRAINT [' + @var1 + '];');
    ALTER TABLE [Exercises] DROP COLUMN [Filename];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var2 sysname;
    SELECT @var2 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exercises]') AND [c].[name] = N'Image');
    IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Exercises] DROP CONSTRAINT [' + @var2 + '];');
    ALTER TABLE [Exercises] DROP COLUMN [Image];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var3 sysname;
    SELECT @var3 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exams]') AND [c].[name] = N'Filename');
    IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [Exams] DROP CONSTRAINT [' + @var3 + '];');
    ALTER TABLE [Exams] DROP COLUMN [Filename];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var4 sysname;
    SELECT @var4 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exams]') AND [c].[name] = N'Image');
    IF @var4 IS NOT NULL EXEC(N'ALTER TABLE [Exams] DROP CONSTRAINT [' + @var4 + '];');
    ALTER TABLE [Exams] DROP COLUMN [Image];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var5 sysname;
    SELECT @var5 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Scores]') AND [c].[name] = N'StuCode');
    IF @var5 IS NOT NULL EXEC(N'ALTER TABLE [Scores] DROP CONSTRAINT [' + @var5 + '];');
    ALTER TABLE [Scores] ALTER COLUMN [StuCode] bigint NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var6 sysname;
    SELECT @var6 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[ExerciseStuTeaches]') AND [c].[name] = N'Date');
    IF @var6 IS NOT NULL EXEC(N'ALTER TABLE [ExerciseStuTeaches] DROP CONSTRAINT [' + @var6 + '];');
    ALTER TABLE [ExerciseStuTeaches] ALTER COLUMN [Date] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var7 sysname;
    SELECT @var7 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exercises]') AND [c].[name] = N'Starttime');
    IF @var7 IS NOT NULL EXEC(N'ALTER TABLE [Exercises] DROP CONSTRAINT [' + @var7 + '];');
    EXEC(N'UPDATE [Exercises] SET [Starttime] = N'''' WHERE [Starttime] IS NULL');
    ALTER TABLE [Exercises] ALTER COLUMN [Starttime] nvarchar(max) NOT NULL;
    ALTER TABLE [Exercises] ADD DEFAULT N'' FOR [Starttime];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var8 sysname;
    SELECT @var8 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exercises]') AND [c].[name] = N'Startdate');
    IF @var8 IS NOT NULL EXEC(N'ALTER TABLE [Exercises] DROP CONSTRAINT [' + @var8 + '];');
    EXEC(N'UPDATE [Exercises] SET [Startdate] = N'''' WHERE [Startdate] IS NULL');
    ALTER TABLE [Exercises] ALTER COLUMN [Startdate] nvarchar(max) NOT NULL;
    ALTER TABLE [Exercises] ADD DEFAULT N'' FOR [Startdate];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var9 sysname;
    SELECT @var9 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exercises]') AND [c].[name] = N'Endtime');
    IF @var9 IS NOT NULL EXEC(N'ALTER TABLE [Exercises] DROP CONSTRAINT [' + @var9 + '];');
    EXEC(N'UPDATE [Exercises] SET [Endtime] = N'''' WHERE [Endtime] IS NULL');
    ALTER TABLE [Exercises] ALTER COLUMN [Endtime] nvarchar(max) NOT NULL;
    ALTER TABLE [Exercises] ADD DEFAULT N'' FOR [Endtime];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var10 sysname;
    SELECT @var10 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exercises]') AND [c].[name] = N'Enddate');
    IF @var10 IS NOT NULL EXEC(N'ALTER TABLE [Exercises] DROP CONSTRAINT [' + @var10 + '];');
    EXEC(N'UPDATE [Exercises] SET [Enddate] = N'''' WHERE [Enddate] IS NULL');
    ALTER TABLE [Exercises] ALTER COLUMN [Enddate] nvarchar(max) NOT NULL;
    ALTER TABLE [Exercises] ADD DEFAULT N'' FOR [Enddate];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var11 sysname;
    SELECT @var11 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exercises]') AND [c].[name] = N'Courseid');
    IF @var11 IS NOT NULL EXEC(N'ALTER TABLE [Exercises] DROP CONSTRAINT [' + @var11 + '];');
    ALTER TABLE [Exercises] ALTER COLUMN [Courseid] bigint NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Exercises] ADD [Score] bigint NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var12 sysname;
    SELECT @var12 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[ExamStuTeaches]') AND [c].[name] = N'Date');
    IF @var12 IS NOT NULL EXEC(N'ALTER TABLE [ExamStuTeaches] DROP CONSTRAINT [' + @var12 + '];');
    ALTER TABLE [ExamStuTeaches] ALTER COLUMN [Date] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var13 sysname;
    SELECT @var13 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exams]') AND [c].[name] = N'Title');
    IF @var13 IS NOT NULL EXEC(N'ALTER TABLE [Exams] DROP CONSTRAINT [' + @var13 + '];');
    ALTER TABLE [Exams] ALTER COLUMN [Title] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var14 sysname;
    SELECT @var14 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Exams]') AND [c].[name] = N'Courseid');
    IF @var14 IS NOT NULL EXEC(N'ALTER TABLE [Exams] DROP CONSTRAINT [' + @var14 + '];');
    ALTER TABLE [Exams] ALTER COLUMN [Courseid] bigint NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Exams] ADD [Capacity] int NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Exams] ADD [Duration] int NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Exams] ADD [PossibleScore] int NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Courses] ADD [Code] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Courses] ADD [Location] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Courses] ADD [Time] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    DECLARE @var15 sysname;
    SELECT @var15 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Calendars]') AND [c].[name] = N'Date');
    IF @var15 IS NOT NULL EXEC(N'ALTER TABLE [Calendars] DROP CONSTRAINT [' + @var15 + '];');
    ALTER TABLE [Calendars] ALTER COLUMN [Date] nvarchar(max) NOT NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Calendars] ADD [Description] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_Scores_Classid] ON [Scores] ([Classid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_Scores_Courseid] ON [Scores] ([Courseid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_Exercises_Classid] ON [Exercises] ([Classid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_Exercises_Courseid] ON [Exercises] ([Courseid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_ExamStuTeaches_Courseid] ON [ExamStuTeaches] ([Courseid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_ExamStuTeaches_Examid] ON [ExamStuTeaches] ([Examid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_ExamStuTeaches_Studentid] ON [ExamStuTeaches] ([Studentid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_ExamStuTeaches_Teacherid] ON [ExamStuTeaches] ([Teacherid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_Exams_Classid] ON [Exams] ([Classid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_Exams_Courseid] ON [Exams] ([Courseid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_Courses_Classid] ON [Courses] ([Classid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    CREATE INDEX [IX_Courses_Teacherid] ON [Courses] ([Teacherid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Courses] ADD CONSTRAINT [FK_Courses_Classes_Classid] FOREIGN KEY ([Classid]) REFERENCES [Classes] ([Classid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Courses] ADD CONSTRAINT [FK_Courses_Teachers_Teacherid] FOREIGN KEY ([Teacherid]) REFERENCES [Teachers] ([Teacherid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Exams] ADD CONSTRAINT [FK_Exams_Classes_Classid] FOREIGN KEY ([Classid]) REFERENCES [Classes] ([Classid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Exams] ADD CONSTRAINT [FK_Exams_Courses_Courseid] FOREIGN KEY ([Courseid]) REFERENCES [Courses] ([Courseid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [ExamStuTeaches] ADD CONSTRAINT [FK_ExamStuTeaches_Courses_Courseid] FOREIGN KEY ([Courseid]) REFERENCES [Courses] ([Courseid]) ON DELETE CASCADE;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [ExamStuTeaches] ADD CONSTRAINT [FK_ExamStuTeaches_Exams_Examid] FOREIGN KEY ([Examid]) REFERENCES [Exams] ([Examid]) ON DELETE CASCADE;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [ExamStuTeaches] ADD CONSTRAINT [FK_ExamStuTeaches_Students_Studentid] FOREIGN KEY ([Studentid]) REFERENCES [Students] ([Studentid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [ExamStuTeaches] ADD CONSTRAINT [FK_ExamStuTeaches_Teachers_Teacherid] FOREIGN KEY ([Teacherid]) REFERENCES [Teachers] ([Teacherid]) ON DELETE CASCADE;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Exercises] ADD CONSTRAINT [FK_Exercises_Classes_Classid] FOREIGN KEY ([Classid]) REFERENCES [Classes] ([Classid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Exercises] ADD CONSTRAINT [FK_Exercises_Courses_Courseid] FOREIGN KEY ([Courseid]) REFERENCES [Courses] ([Courseid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Scores] ADD CONSTRAINT [FK_Scores_Classes_Classid] FOREIGN KEY ([Classid]) REFERENCES [Classes] ([Classid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    ALTER TABLE [Scores] ADD CONSTRAINT [FK_Scores_Courses_Courseid] FOREIGN KEY ([Courseid]) REFERENCES [Courses] ([Courseid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251130150052_AddExamFieldsAndDbSet'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251130150052_AddExamFieldsAndDbSet', N'9.0.10');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    EXEC sp_rename N'[Scores].[StuCode]', N'Studentid', 'COLUMN';
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    ALTER TABLE [ExerciseStuTeaches] ADD [Time] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    ALTER TABLE [Exercises] ADD [File] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    ALTER TABLE [Exercises] ADD [Filename] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    ALTER TABLE [ExamStuTeaches] ADD [Time] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    ALTER TABLE [Exams] ADD [File] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    ALTER TABLE [Exams] ADD [Filename] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    DECLARE @var16 sysname;
    SELECT @var16 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Courses]') AND [c].[name] = N'Name');
    IF @var16 IS NOT NULL EXEC(N'ALTER TABLE [Courses] DROP CONSTRAINT [' + @var16 + '];');
    ALTER TABLE [Courses] ALTER COLUMN [Name] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    DECLARE @var17 sysname;
    SELECT @var17 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Classes]') AND [c].[name] = N'Name');
    IF @var17 IS NOT NULL EXEC(N'ALTER TABLE [Classes] DROP CONSTRAINT [' + @var17 + '];');
    ALTER TABLE [Classes] ALTER COLUMN [Name] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    DECLARE @var18 sysname;
    SELECT @var18 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Classes]') AND [c].[name] = N'Grade');
    IF @var18 IS NOT NULL EXEC(N'ALTER TABLE [Classes] DROP CONSTRAINT [' + @var18 + '];');
    ALTER TABLE [Classes] ALTER COLUMN [Grade] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132222_SyncStudentidColumn'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251230132222_SyncStudentidColumn', N'9.0.10');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132400_SyncStudentidColumnn'
)
BEGIN
    ALTER TABLE [Scores] ADD [StuCode] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132400_SyncStudentidColumnn'
)
BEGIN
    CREATE INDEX [IX_Scores_Studentid] ON [Scores] ([Studentid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132400_SyncStudentidColumnn'
)
BEGIN
    ALTER TABLE [Scores] ADD CONSTRAINT [FK_Scores_Students_Studentid] FOREIGN KEY ([Studentid]) REFERENCES [Students] ([Studentid]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251230132400_SyncStudentidColumnn'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251230132400_SyncStudentidColumnn', N'9.0.10');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260209175438_InitialCreate'
)
BEGIN
    DECLARE @var19 sysname;
    SELECT @var19 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Students]') AND [c].[name] = N'Registerdate');
    IF @var19 IS NOT NULL EXEC(N'ALTER TABLE [Students] DROP CONSTRAINT [' + @var19 + '];');
    ALTER TABLE [Students] ALTER COLUMN [Registerdate] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260209175438_InitialCreate'
)
BEGIN
    DECLARE @var20 sysname;
    SELECT @var20 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Students]') AND [c].[name] = N'Birthdate');
    IF @var20 IS NOT NULL EXEC(N'ALTER TABLE [Students] DROP CONSTRAINT [' + @var20 + '];');
    ALTER TABLE [Students] ALTER COLUMN [Birthdate] nvarchar(max) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260209175438_InitialCreate'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260209175438_InitialCreate', N'9.0.10');
END;

COMMIT;
GO

