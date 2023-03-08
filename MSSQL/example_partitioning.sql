-- 1 Step 
-- Create function for partitioning

CREATE PARTITION FUNCTION part_function (date)
AS RANGE RIGHT FOR VALUES ('2021-08-12', '2021-08-13'); --dates what i'm using - mu current date + 1 day (second date)

-- 2 Step
-- Create schema for partitioning (we will use created paririon function at step 1)

CREATE PARTITION SCHEME part_schema AS PARTITION part_function ALL TO ([PRIMARY]);

-- 3 Step 
-- Create table - in my case it's copy of my view and place where i should use my partitioning

CREATE TABLE [dbo].[table_with_logs](
	[ITEM_CODE] [int] NULL,
	[GROUP_CODE] [nvarchar](150) NULL,
	[BRANCH_CODE] [nvarchar](150) NULL,
	[FROM_DATE] [date] NOT NULL,
	[TO_DATE] [date] NULL,
	[LOG_DATE] [date] NOT NULL
) ON part_schema ([LOG_DATE]) --here we use our partition schema wich we created on Step 2


-- 4 Step
-- Create procedure which made the process AUTOMATIC
CREATE PROCEDURE [schema_name].[procedute_name]
as

BEGIN
	BEGIN
	-- Before create a new partition we should check the existence of it
	-- That's why i use select to find max partition date
	DECLARE  @max_partition date 
	SELECT @max_partition = CAST (MAX(prv.value) as date)
	FROM sys.tables tbl
	JOIN sys.indexes idx ON idx.object_id = tbl.object_id
	JOIN sys.data_spaces dts ON dts.data_space_id = idx.data_space_id
	JOIN sys.partitions prt ON prt.object_id = tbl.object_id AND prt.index_id =idx.index_id
	LEFT JOIN sys.partition_schemes prs ON prs.data_space_id = dts.data_space_id
	LEFT JOIN sys.partition_functions pfs ON pfs.function_id = prs.function_id
	LEFT JOIN sys.partition_range_values prv ON
	      prv.function_id = pfs.function_id AND prv.boundary_id =prt.partition_number - 1
	LEFT JOIN sys.destination_data_spaces dds ON
	      dds.partition_scheme_id = prs.data_space_id    AND dds.destination_id =prt.partition_number
	LEFT JOIN sys.data_spaces dts2 ON dts2.data_space_id = dds.data_space_id
	where tbl.object_id=object_id('[dbo].[table_with_logs]')

	-- Get current date for comparing with max existing partition date 
	DECLARE @current_date date
	SELECT @current_date = convert(varchar, getdate(), 23 )

	IF @max_partition = @current_date
	-- IF we need to refresh log for this day - DELETE current date from log table
	DELETE FROM [dbo].[table_with_logs] WHERE [LOG_DATE] = @current_date
	-- In case we have no partition we do:
	ELSE  
		BEGIN
			-- Choose next file group for next partition
			ALTER PARTITION SCHEME part_schema
			NEXT USED [PRIMARY]
			-- Create a new partition
			ALTER PARTITION  FUNCTION part_function()
			SPLIT RANGE (@current_date)
		END
	END
	
	BEGIN
	-- Insert your log for current day in created partition
	INSERT INTO [dbo].[table_with_logs] 
	(	
		[ITEM_CODE],
		[GROUP_CODE],
		[BRANCH_CODE],
		[FROM_DATE],
		[TO_DATE],
		[LOG_DATE]
	)
	SELECT
		[ITEM_CODE],
		[GROUP_CODE],
		[BRANCH_CODE],
		[FROM_DATE],
		[TO_DATE],
		@current_date
	FROM [dbo].vSOURCE4LOG --Source of my log table
	END
	
	BEGIN
	-- LOG table can't beeing infinite that's why i delete old DATABASE
	-- I need to store +- 1 week
	DECLARE  @min_partition date; 
	SELECT @min_partition = CAST (MIN(prv.value) as date)
	FROM sys.tables tbl
	JOIN sys.indexes idx ON idx.object_id = tbl.object_id
	JOIN sys.data_spaces dts ON dts.data_space_id = idx.data_space_id
	JOIN sys.partitions prt ON prt.object_id = tbl.object_id AND prt.index_id =idx.index_id
	LEFT JOIN sys.partition_schemes prs ON prs.data_space_id = dts.data_space_id
	LEFT JOIN sys.partition_functions pfs ON pfs.function_id = prs.function_id
	LEFT JOIN sys.partition_range_values prv ON
	      prv.function_id = pfs.function_id AND prv.boundary_id =prt.partition_number - 1
	LEFT JOIN sys.destination_data_spaces dds ON
	      dds.partition_scheme_id = prs.data_space_id    AND dds.destination_id =prt.partition_number
	LEFT JOIN sys.data_spaces dts2 ON dts2.data_space_id = dds.data_space_id
	where tbl.object_id=object_id('[dbo].[table_with_logs]')

	-- Get tha date which is minimum interval of log storage
	DECLARE @min_log_date date
	SELECT @min_log_date = convert(varchar, DATEADD(dd,-7, getdate()), 23 )	

	IF @min_partition < @min_log_date
	BEGIN
		-- Here we delete the old partition/partitions (if you want you can use [LOG_DATE] <= @min_partition)
		DELETE FROM [dbo].[table_with_logs]
		WHERE [LOG_DATE] = @min_partition
		-- We should merge the space of partition which we deleted (merge 0 rows to a new last partition with some data)
		ALTER PARTITION  FUNCTION part_function()
		MERGE RANGE (@min_partition)
		END
	END
	
END

-- Then you can use it in SSIS package and run the last procedute automaticly when you want