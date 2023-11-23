
---ckeck the memmory clerk on sql server
select * from sys.dm_os_memory_clerks
order by pages_kb desc

---DMV
select * from sys.dm_os_buffer_descriptors

----Get the buffer pool utilization by each database

select DBNAME =  CASE WHEN  database_id = 32767 THEN 'RSOURCEDB'
				ELSE DB_NAME(database_id) END,
	Size_MB = COUNT(1)/128
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY 2 DESC



-----get buffer pool utilisation by each object in a database

use TruDat
go
select DBNAME =  CASE WHEN  database_id = 32767 THEN 'RSOURCEDB'
				ELSE DB_NAME(database_id) END,
		OBJnAME = O.NAME,
	Size_MB = COUNT(1)/128

	FROM sys.dm_os_buffer_descriptors obd

	inner join sys.allocation_units au
	on obd.allocation_unit_id = au.allocation_unit_id
	inner join sys.partitions p
	on au.container_id = p.hobt_id
	inner join sys.objects o
	on p.object_id = o.object_id

	where obd.database_id = DB_ID()
	AND o.type != 'S'
	GROUP BY obd.database_id, o.name
	ORDER BY 3 DESC


--	DBNAME	OBJnAME	                      Size_MB
DataSynchronizerConfig	Log	               116946
DataSynchronizerConfig	Detail	            10899
DataSynchronizerConfig	PersistTimingLog	2442

---After
DBNAME	                OBJnAME	         Size_MB
DataSynchronizerConfig	Log	               88538
DataSynchronizerConfig	Detail	           11490
DataSynchronizerConfig	PersistTimingLog	3918



--Updated the stats on the objects
---Memory consumption dropped from 130 GB to 103 GB

-----CHECK STATISTICS UPDATE ON DATABASE OBJECTS

USE [DataSynchronizerConfig]; -- Replace with the name of your database

DECLARE @ObjectName NVARCHAR(256) = 'PersistTimingLog'; -- Replace with the name of your table or index

-- Check statistics updates for a specific table or index

SELECT
    OBJECT_NAME(stats.object_id) AS TableName,
    stats.name AS StatisticName,
    stats.stats_id AS StatisticID,
    sp.last_updated AS LastUpdated,
    sp.rows AS RowsModified,
    sp.rows_sampled AS RowsSampled,
    sp.steps AS Steps,
    sp.modification_counter AS ModificationCounter
FROM
    sys.stats AS stats
CROSS APPLY
    sys.dm_db_stats_properties(stats.object_id, stats.stats_id) AS sp
WHERE
    OBJECT_NAME(stats.object_id) = @ObjectName;

---Update statistics
	use [DataSynchronizerConfig]
GO
UPDATE STATISTICS [Instrumentation].[PersistTimingLog][pk_instrumentationpersisttiminglog_id]
GO


-----CHECK THE NUMA NODE 

SELECT * from sys.dm_os_nodes