--Assertions for Azure SQL 15 documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 13 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 675 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId, 691); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (172); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 450 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 676
    AND [fk_table_id] = 675
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 593 -- Declare appropriate unique_constraint_id from 675] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 594 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 6093; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 348; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 680; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 690; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 609; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 610; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for Azure Synapse Analytics documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 23 -- Declare database_id from dbo.databases appropriate to tested documentation

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (1122); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = 1122 -- Declare object_id from (most likely) dbo.tables appropriate to tested documentation
)
BEGIN
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 451 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 1122
    AND [fk_table_id] = 1122
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 595 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 1122 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 596 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 1122 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 12371; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = 1122; -- Declare appropriate table_id from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
        SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 349; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = 1122; -- Declare appropriate processor_id from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 948; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 971; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 611; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 612; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests

IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for Azure Synapse Pipelines documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 14 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 695 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (187); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 452 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 695
    AND [fk_table_id] = 695
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 597 -- Declare appropriate unique_constraint_id from 675] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 598 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 6247; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 350; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 964; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 988; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 613; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 614; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for MariaDB documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 18 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 995 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId, 1011); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (221); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 453 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 997
    AND [fk_table_id] = 995
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 599 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 600 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 10854; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage 
DECLARE @LineageProcessId INT = 351; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 391; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 494; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 615; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 616; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for MySQL 5 documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 16 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 948 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId, 1011); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (209); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 454 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 964
    AND [fk_table_id] = 948
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 601 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 602 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 10590; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage 
DECLARE @LineageProcessId INT = 353; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 974; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 951; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 617; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 618; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for MySQL 8 documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 17 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 971 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId, 988); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (215); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 455 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 988
    AND [fk_table_id] = 971
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 816 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 817 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 10721; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage 
DECLARE @LineageProcessId INT = 885; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 988; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 514; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 1440; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 1441; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for Oracle11g documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 2 -- Declare database_id from dbo.databases appropriate to tested documentation

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (37, 219); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (37, 49); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = 37 -- Declare object_id from (most likely) dbo.tables appropriate to tested documentation
)
BEGIN
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 499 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 58
    AND [fk_table_id] = 37
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 639 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 37 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 640 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 37 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 422; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = 37; -- Declare appropriate table_id from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 369; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = 37; -- Declare appropriate processor_id from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 974; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 496; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 1348; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 1349; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests

IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for Oracle23c documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 3 -- Declare database_id from dbo.databases appropriate to tested documentation

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (251, 298); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (86, 90); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = 251 -- Declare object_id from (most likely) dbo.tables appropriate to tested documentation
)
BEGIN
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 501 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 298
    AND [fk_table_id] = 251
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 641 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 251 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 642 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 251 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 2059; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = 251; -- Declare appropriate table_id from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 373; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = 251; -- Declare appropriate processor_id from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 974; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 496; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 1035; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 1036; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests

IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for Power BI Report Server documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 25 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 1124 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
--Module for reports table

DECLARE @ReportId INT;
DECLARE @ReportName NVARCHAR(255);
DECLARE @ReportObjectType NVARCHAR(255);
DECLARE @ReportNullFields NVARCHAR(MAX);

DECLARE ReportCursor CURSOR FOR
SELECT [report_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[reports]
WHERE [database_id] = @DatabaseId
  AND [report_id] IN (32); -- Declare report_id(s) from dbo.reports appropriate to tested documentation

-- Loop through reports using a cursor
-- Fetch next report details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ReportCursor;
FETCH NEXT FROM ReportCursor INTO @ReportId, @ReportName, @ReportObjectType;

SET @ReportNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[reports] WHERE [report_id] = @ReportId AND [title] IS NULL)
        SET @ReportNullFields = @ReportNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[reports] WHERE [report_id] = @ReportId AND [description] IS NULL)
        SET @ReportNullFields = @ReportNullFields + 'Description, ';

    IF LEN(@ReportNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ReportName + ' (' + @ReportObjectType + ') in field(s): ' + @ReportNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ReportName + ' (' + @ReportObjectType + ') - test passed';
    END

    FETCH NEXT FROM ReportCursor INTO @ReportId, @ReportName, @ReportObjectType;
END

CLOSE ReportCursor;
DEALLOCATE ReportCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 620 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 1137
    AND [fk_table_id] = 1124
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 649 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 650 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 12402; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 380; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 255; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 275; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 1435; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 671; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
    -- Same objct cannot be an inflow and an outflow
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO 

--Assertions for PostgreSQL 9 documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 8 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 390 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId, 407); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (109); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 503 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 407
    AND [fk_table_id] = 390
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 645 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 646 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 4772; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 376; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 950; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 973; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 666; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 667; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for PostgreSQL 15 documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 10 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 493 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId, 514); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (122); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 502 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 514
    AND [fk_table_id] = 493
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 643 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 644 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 5362; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 374; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 948; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 971; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 664; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 665; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for Power BI documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 4 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 304 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;

--Module for reports table

DECLARE @ReportId INT;
DECLARE @ReportName NVARCHAR(255);
DECLARE @ReportObjectType NVARCHAR(255);
DECLARE @ReportNullFields NVARCHAR(MAX);

DECLARE ReportCursor CURSOR FOR
SELECT [report_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[reports]
WHERE [database_id] = @DatabaseId
  AND [report_id] IN (1, 12); -- Declare report_id(s) from dbo.reports appropriate to tested documentation

-- Loop through reports using a cursor
-- Fetch next report details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ReportCursor;
FETCH NEXT FROM ReportCursor INTO @ReportId, @ReportName, @ReportObjectType;

SET @ReportNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[reports] WHERE [report_id] = @ReportId AND [title] IS NULL)
        SET @ReportNullFields = @ReportNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[reports] WHERE [report_id] = @ReportId AND [description] IS NULL)
        SET @ReportNullFields = @ReportNullFields + 'Description, ';

    IF LEN(@ReportNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ReportName + ' (' + @ReportObjectType + ') in field(s): ' + @ReportNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ReportName + ' (' + @ReportObjectType + ') - test passed';
    END

    FETCH NEXT FROM ReportCursor INTO @ReportId, @ReportName, @ReportObjectType;
END

CLOSE ReportCursor;
DEALLOCATE ReportCursor;

 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 505 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 306
    AND [fk_table_id] = 304
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 651 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 652 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 2414; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 382; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 971; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 995; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 1407; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 1408; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows
    -- This method will not work if for some reason the same object would be its inflow and outflow 

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for Power BI Datasets documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255);
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255); 
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 7 -- Declare database_id from dbo.databases appropriate to tested documentation

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
 
    SET @DatabaseNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
 
 	-- Check if unexpected NULL values are found for database description

    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END
 
-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (366); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks 
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
 
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';

 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END
 
    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END
 
CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = 366 -- Declare object_id from (most likely) dbo.tables appropriate to tested documentation
)
BEGIN
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row
SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 504 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 366
    AND [fk_table_id] = 366
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys

IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 647 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 366 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 648 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 366 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Columns module
DECLARE @ColumnId INT = 4472; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = 366; -- Declare appropriate table_id from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;
 
       -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END
 
    -- Check for lookup_id = 1
     IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
							   
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END
 
--Module for Data lineage 
 
DECLARE @LineageProcessId INT = 378; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = 366; -- Declare appropriate processor_id from dbo.data_processes appropriate to tested documentation						 
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 393; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 496; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 668; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 669; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;

END

-- Final message
-- Display a final message based on the results of all the tests

IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
							  
END
;

GO

--Assertions for Snowflake documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 11 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 521 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId, 574, 584); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);

DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (140); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;

SET @ProcedureNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';

    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END

CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 506 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 522
    AND [fk_table_id] = 521
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 653 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 654 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 5527; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 387; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 535; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 534; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 676; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 677; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for SQL Server 2008 documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255);
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255); 
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 31 -- Declare database_id from dbo.databases appropriate to tested documentation

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
 
    SET @DatabaseNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
 
 	-- Check if unexpected NULL values are found for database description

    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END
 
-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (1147, 1174); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks 
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
 
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';

 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END
 
    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END
 
CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);
 
DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (224); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
 
SET @ProcedureNullFields = '';
 
WHILE @@FETCH_STATUS = 0
BEGIN
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';
 
    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END
 
CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = 1147 -- Declare object_id from (most likely) dbo.tables appropriate to tested documentation
)
BEGIN
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row
SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 507 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 1155
    AND [fk_table_id] = 1147
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys

IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 655 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 1147 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 656
    AND [table_id] = 1147
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Columns module
DECLARE @ColumnId INT = 12750; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = 1147; -- Declare appropriate table_id from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;
 
       -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END
 
    -- Check for lookup_id = 1
     IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
							   
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END
 
--Module for Data lineage 
 
DECLARE @LineageProcessId INT = 389; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = 1147; -- Declare appropriate processor_id from dbo.data_processes appropriate to tested documentation						 
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 12; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 340; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 678; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 679; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;

END

-- Final message
-- Display a final message based on the results of all the tests

IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
							  
END

;

GO

--Assertions for SQL Server 2019 documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255);
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255); 
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 1 -- Declare database_id from dbo.databases appropriate to tested documentation

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
 
    SET @DatabaseNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
 
 	-- Check if unexpected NULL values are found for database description

    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END
 
-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (251, 298); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks 
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
 
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';

 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END
 
    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END
 
CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
-- Module for procedures table
DECLARE @ProcedureObjectId INT;
DECLARE @ProcedureObjectName NVARCHAR(255);
DECLARE @ProcedureObjectType NVARCHAR(255);
DECLARE @ProcedureNullFields NVARCHAR(MAX);
 
DECLARE ProcedureCursor CURSOR FOR
SELECT [procedure_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[procedures]
WHERE [database_id] = @DatabaseId
  AND [procedure_id] IN (8); -- Declare procedure_id(s) from dbo.procedures appropriate to tested documentation

-- Loop through procedures using a cursor
-- Fetch next procedure details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ProcedureCursor;
FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
 
SET @ProcedureNullFields = '';
 
WHILE @@FETCH_STATUS = 0
BEGIN
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [title] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_plain] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[procedures] WHERE [procedure_id] = @ProcedureObjectId AND [description_search] IS NULL)
        SET @ProcedureNullFields = @ProcedureNullFields + 'Description_search, ';
 
    IF LEN(@ProcedureNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') in field(s): ' + @ProcedureNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ProcedureObjectName + ' (' + @ProcedureObjectType + ') - test passed';
    END

    FETCH NEXT FROM ProcedureCursor INTO @ProcedureObjectId, @ProcedureObjectName, @ProcedureObjectType;
END
 
CLOSE ProcedureCursor;
DEALLOCATE ProcedureCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = 2 -- Declare object_id from (most likely) dbo.tables appropriate to tested documentation
)
BEGIN
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row
SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 529 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 3
    AND [fk_table_id] = 2
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys

IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 657 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = 2 -- Declare appropriate table_id from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 658
    AND [table_id] = 2
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Columns module
DECLARE @ColumnId INT = 3; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = 2; -- Declare appropriate table_id from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;
 
       -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END
 
    -- Check for lookup_id = 1
     IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
							   
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END
 
--Module for Data lineage 
 
DECLARE @LineageProcessId INT = 391; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = 2; -- Declare appropriate processor_id from dbo.data_processes appropriate to tested documentation						 
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 974; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 496; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 680; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 681; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;

END

-- Final message
-- Display a final message based on the results of all the tests

IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
							  
END
;

GO

--Assertions for Tableau documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 15 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 853 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 
--Module for reports table

DECLARE @ReportId INT;
DECLARE @ReportName NVARCHAR(255);
DECLARE @ReportObjectType NVARCHAR(255);
DECLARE @ReportNullFields NVARCHAR(MAX);

DECLARE ReportCursor CURSOR FOR
SELECT [report_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[reports]
WHERE [database_id] = @DatabaseId
  AND [report_id] IN (13); -- Declare report_id(s) from dbo.reports appropriate to tested documentation

-- Loop through reports using a cursor
-- Fetch next report details
-- Check for NULL values in title, description, and other fields
-- Display appropriate messages based on NULL checks

OPEN ReportCursor;
FETCH NEXT FROM ReportCursor INTO @ReportId, @ReportName, @ReportObjectType;

SET @ReportNullFields = '';

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[reports] WHERE [report_id] = @ReportId AND [title] IS NULL)
        SET @ReportNullFields = @ReportNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[reports] WHERE [report_id] = @ReportId AND [description] IS NULL)
        SET @ReportNullFields = @ReportNullFields + 'Description, ';

    IF LEN(@ReportNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ReportName + ' (' + @ReportObjectType + ') in field(s): ' + @ReportNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ReportName + ' (' + @ReportObjectType + ') - test passed';
    END

    FETCH NEXT FROM ReportCursor INTO @ReportId, @ReportName, @ReportObjectType;
END

CLOSE ReportCursor;
DEALLOCATE ReportCursor;
 
-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 622 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 933
    AND [fk_table_id] = 853
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 661 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 662 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 7667; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 395; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 100; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 169; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 684; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 685; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
    -- Same objct cannot be an inflow and an outflow
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END
;

GO

--Assertions for Power Tableau Data Model documentation to perform after repository upgrade and importing changes

USE dataedo_meta_upgrade_cs;

DECLARE @DatabaseNullFields NVARCHAR(MAX);
DECLARE @TableNullFields NVARCHAR(MAX);
DECLARE @UnexpectedNullFields NVARCHAR(MAX) = '';
DECLARE @ObjectId INT;
DECLARE @ObjectName NVARCHAR(255); 
DECLARE @ObjectType NVARCHAR(255);
DECLARE @UnexpectedNulls INT = 0;
DECLARE @ColumnName NVARCHAR(255);
DECLARE @TableName NVARCHAR(255);
DECLARE @NullFields NVARCHAR(MAX);
DECLARE @ManualColumnNotFound INT = 0; 
DECLARE @DataLineageTestFailed INT = 0;
DECLARE @DatabaseId INT = 19 -- Declare database_id from dbo.databases appropriate to tested documentation
DECLARE @TableId INT = 1035 -- Declare table_id from dbo.databases appropriate to tested documentation (the main table used for most or all manual objects)

-- Module for databases table

-- Check if the specified database exists
IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId)
BEGIN
    SET @DatabaseNullFields = '';

    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_plain] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[databases] WHERE [database_id] = @DatabaseId AND [description_search] IS NULL)
        SET @DatabaseNullFields = @DatabaseNullFields + 'Description_search, ';
		 
	-- Check if unexpected NULL values are found for database description
    IF LEN(@DatabaseNullFields) > 0
    BEGIN
        SET @DatabaseNullFields = LEFT(@DatabaseNullFields, LEN(@DatabaseNullFields) - 1);
        PRINT 'Unexpected NULL values found for database description in field(s): ' + @DatabaseNullFields + ' - TEST FAILED';
		SET @UnexpectedNulls = @UnexpectedNulls + 1;
	END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for database description - test passed';
    END
END
ELSE
BEGIN
    PRINT 'Specified database does not exist - TEST FAILED';
END

-- Module for tables table
DECLARE ObjectCursor CURSOR FOR
SELECT [table_id], [name], [object_type]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables]
WHERE [database_id] = @DatabaseId 
  AND [table_id] IN (@TableId); -- Declare table_id(s) from dbo.tables appropriate to tested documentation

-- Loop through tables using a cursor
-- Fetch next table details
-- Check for NULL values in title and description fields
-- Display appropriate messages based on NULL checks
OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableNullFields = '';
    SET @UnexpectedNullFields = '';
 
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [title] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Title, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_plain] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_plain, ';
    IF EXISTS (SELECT 1 FROM [dataedo_meta_upgrade_cs].[dbo].[tables] WHERE [table_id] = @ObjectId AND [description_search] IS NULL)
        SET @TableNullFields = @TableNullFields + 'Description_search, ';
 
    IF LEN(@TableNullFields) > 0
    BEGIN
        PRINT 'Unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') in field(s): ' + @TableNullFields + ' - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
    ELSE
    BEGIN
        PRINT 'No unexpected NULL values found for ' + @ObjectName + ' (' + @ObjectType + ') - test passed';
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectId, @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
 

-- Module for glossary_mappings table

-- Check if there is a link between a database object and term
-- Display appropriate messages based on the existence of the link
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[glossary_mappings]
    WHERE [object_id] = @TableId -- Declare object_id from (most likely the main table, change if necessary) dbo.tables appropriate to tested documentation
)
BEGIN 
    PRINT 'Expected link between database object and term found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected link between term and object not found - TEST FAILED.';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for tables_relations table
DECLARE @TableRelationId INT;
DECLARE @PkTableId INT;
DECLARE @FkTableId INT;
DECLARE @Source NVARCHAR(255);
DECLARE @Status NVARCHAR(1);
 
-- Check if there is a specific row in tables_relations with specified criteria
-- Display appropriate messages based on the existence of the row

SELECT TOP 1
    @TableRelationId = [table_relation_id],
    @PkTableId = [pk_table_id],
    @FkTableId = [fk_table_id],
    @Source = [source],
    @Status = [status]
FROM [dataedo_meta_upgrade_cs].[dbo].[tables_relations]
WHERE [table_relation_id] = 621 -- Declare appropriate ids from dbo.tables_relations appropriate to tested documentation
    AND [pk_table_id] = 1036
    AND [fk_table_id] = 1035
    AND [source] = 'USER'
    AND [status] = 'A';
 
IF @TableRelationId IS NOT NULL
BEGIN
    PRINT 'Row found in tables_relations with specified criteria - test passed';
END
ELSE
BEGIN
    PRINT 'Row not found in tables_relations with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
-- Module for unique_constraints table
SET @NullFields = '';

-- Check for expected primary and unique keys in the unique_constraints table
-- Display appropriate messages based on the existence of the keys
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 814 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 1
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected primary key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected primary key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END
 
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[unique_constraints]
    WHERE [unique_constraint_id] = 815 -- Declare appropriate unique_constraint_id from dbo.unique_constraints] appropriate to tested documentation
    AND [table_id] = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation (object that has keys added)
    AND [source] = 'USER'
    AND [primary_key] = 0
    AND [status] = 'A'
)
BEGIN
    PRINT 'Expected unique key found - test passed';
END
ELSE
BEGIN
    PRINT 'Expected unique key not found - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Columns module
DECLARE @ColumnId INT = 11259; -- Declare appropriate column_id from dbo.columns appropriate to tested documentation
DECLARE @tableColumnId INT = @TableId -- Declare appropriate table_id (if different then declared) from dbo.tables appropriate to tested documentation
DECLARE @TitleIsNull INT;
DECLARE @DescriptionIsNull INT;
DECLARE @UnexpectedNullFieldsFound INT;

-- Check if there is a row with specific conditions in columns table for column_id = @ColumnId
-- Display appropriate messages based on NULL checks and lookup_id
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE C.[column_id] = @ColumnId
      AND C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'DBMS'
)
BEGIN
    -- Get column and table names for messages
    SELECT @ColumnName = C.[name],
           @TableName = T.[name],
           @TitleIsNull = CASE WHEN C.[title] IS NULL THEN 1 ELSE 0 END,
           @DescriptionIsNull = CASE WHEN C.[description] IS NULL THEN 1 ELSE 0 END
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    JOIN [dataedo_meta_upgrade_cs].[dbo].[tables] T ON C.[table_id] = T.[table_id]
    WHERE C.[column_id] = @ColumnId;

    -- Check for NULL values in [title] and [description]
    IF @TitleIsNull = 1 OR @DescriptionIsNull = 1
    BEGIN
	    SET @UnexpectedNullFieldsFound = 1
        -- Check for NULL in [title]
        IF @TitleIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Title, ';

        -- Check for NULL in [description]
        IF @DescriptionIsNull = 1
            SET @UnexpectedNullFields = @UnexpectedNullFields + 'Description, ';

        SET @UnexpectedNullFields = LEFT(@UnexpectedNullFields, LEN(@UnexpectedNullFields) - 1);

        -- Display appropriate message based on NULL checks
        IF LEN(@UnexpectedNullFields) > 0
        BEGIN
            PRINT 'Unexpected NULL value(s) found for ' + @ColumnName + ' in table ' + @TableName + ' in field(s): ' + @UnexpectedNullFields + ' - TEST FAILED';
        END
        ELSE
        BEGIN
            PRINT 'Expected description and title of a column found - test passed';
        END
    END
    ELSE
    BEGIN
        SET @UnexpectedNullFieldsFound = 0
        -- If both [title] and [description] are not NULL
        PRINT 'Expected description and title of a column found - test passed';
    END

    -- Check for lookup_id = 1
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
        WHERE C.[column_id] = @ColumnId
          AND C.[table_id] = @tableColumnId
          AND C.[status] = 'A'
          AND C.[source] = 'DBMS'
          AND C.[lookup_id] = 1
    )
    BEGIN
        PRINT 'Lookup link found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Lookup link not found - TEST FAILED';
        SET @UnexpectedNulls = @UnexpectedNulls + 1;
    END
END
ELSE
BEGIN
    -- If the initial conditions are not met
    PRINT 'Row not found in columns with specified criteria - TEST FAILED';
    SET @UnexpectedNulls = @UnexpectedNulls + 1;
END

-- Check if there is a row with specific conditions in columns table for user-made column
-- Display appropriate messages based on the existence of the manual column
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[columns] C
    WHERE  C.[table_id] = @tableColumnId
      AND C.[status] = 'A'
      AND C.[source] = 'USER'
)
BEGIN
    -- Display message if the manual column found
    PRINT 'Expected manual column found - test passed';
END
ELSE
BEGIN
    -- Display message if the manual column found is not found
    PRINT 'Row not found for manual column with specified criteria - TEST FAILED';
    SET @ManualColumnNotFound = 1;
END

-- Module for Data lineage
DECLARE @LineageProcessId INT = 884; -- Declare appropriate process_id from dbo.data_processes appropriate to tested documentation (search by plain_description)
DECLARE @ProcessorId INT = @TableId; -- Declare appropriate processor_id (most likely of the mian table change if needed) from dbo.data_processes appropriate to tested documentation
DECLARE @ExpectedProcessorName NVARCHAR(255) = 'Regression';
DECLARE @ObjectFlowId1 INT = 971; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @ObjectFlowId2 INT = 493; -- Declare appropriate object_id from dbo.data_flows appropriate to tested documentation
DECLARE @InflowId INT = 1438; -- Declare appropriate inflow_id from dbo.data_flows appropriate to tested documentation
DECLARE @OutflowId INT = 1439; -- Declare appropriate outflow_id from dbo.data_flows appropriate to tested documentation

-- Check if the lineage process exists in [data_processes]
-- Display appropriate messages based on the existence of the process
IF EXISTS (
    SELECT 1
    FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes]
    WHERE [process_id] = @LineageProcessId
      AND [processor_id] = @ProcessorId
      AND [source] = 'USER'
)
BEGIN
    -- Check if the processor has the expected name
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_processes] DP
        WHERE [process_id] = @LineageProcessId
          AND [processor_id] = @ProcessorId
          AND [source] = 'USER'
          AND [name] = @ExpectedProcessorName
    )
    BEGIN
        PRINT 'Expected data lineage process found';
    END
    ELSE
    BEGIN
        PRINT 'Expected lineage process found with unexpected name - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for object level flows in [data_flows]
    -- Same objct cannot be an inflow and an outflow
	-- Display appropriate messages based on the count of object level flows

    IF (
        SELECT COUNT(DISTINCT [object_id])
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_flows]
        WHERE [process_id] = @LineageProcessId
          AND ([object_id] = @ObjectFlowId1 OR [object_id] = @ObjectFlowId2)
    ) = 2
    BEGIN
        PRINT 'Expected values for object level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some object level flows missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END

    -- Check for column level lineage values in [data_columns_flows]
	-- Display appropriate messages based on the existence of column level flows
    IF EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [inflow_id] = @InflowId
    )
    AND EXISTS (
        SELECT 1
        FROM [dataedo_meta_upgrade_cs].[dbo].[data_columns_flows]
        WHERE [outflow_id] = @OutflowId
    )
    BEGIN
        PRINT 'Expected values for column level flows found - test passed';
    END
    ELSE
    BEGIN
        PRINT 'Some expected values for column level lineage missing - TEST FAILED';
        SET @DataLineageTestFailed = 1;
    END
END
ELSE
BEGIN
    PRINT 'Expected lineage process not found - TEST FAILED';
    SET @DataLineageTestFailed = 1;
END

-- Final message
-- Display a final message based on the results of all the tests
IF @UnexpectedNulls = 0 AND @ManualColumnNotFound = 0 AND @DataLineageTestFailed = 0 AND @UnexpectedNullFieldsFound = 0
BEGIN
    PRINT 'All tests passed successfully!';
END
ELSE
BEGIN
    PRINT 'Some tests failed. Please review the output for details.';
END

