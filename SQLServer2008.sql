--Assertions for SQL Server 2008 documentation to perform after repository upgrade and importing changes

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

