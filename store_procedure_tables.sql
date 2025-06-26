CREATE OR ALTER PROCEDURE sp_create_external_table
    @table_name NVARCHAR(100)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @full_table_name NVARCHAR(200);
    DECLARE @location NVARCHAR(200);

    -- Build full external table name and location
    SET @full_table_name = QUOTENAME('parrot') + '.' + QUOTENAME(@table_name);
    SET @location = @table_name;  -- assumes folder name matches table name

    -- Drop the external table if it already exists
    IF EXISTS (
        SELECT * FROM sys.external_tables WHERE name = @table_name AND schema_id = SCHEMA_ID('parrot')
    )
    BEGIN
        SET @sql = 'DROP EXTERNAL TABLE ' + @full_table_name;
        EXEC sp_executesql @sql;
    END

    -- Re-create the external table from the corresponding view
    SET @sql = '
        CREATE EXTERNAL TABLE ' + @full_table_name + '
        WITH (
            LOCATION = ''' + @location + ''',
            DATA_SOURCE = source_sql,
            FILE_FORMAT = format_parquet
        )
        AS
        SELECT * FROM dbo.' + QUOTENAME(@table_name) + ';
    ';

    EXEC sp_executesql @sql;
END;
