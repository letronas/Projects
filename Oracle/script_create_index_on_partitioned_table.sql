--Create partitioned index in tab which is already partitioned and have a DATABASE
--This code is for situation when you need to manage a TBS for a partitions of index
--Because if you just create a local it would be one same TBS everywhere 
declare
    v_sql clob; -- clob is better than 32767 varchar2 because of the rows inside LOCAL clause
    v_tab_owner varchar2(14) := 'SCHEMA_NAME'; 
    v_tab_name varchar2(128) := 'TABLE_NAME';
    v_key_columns varchar2(32767) := 'INDEX_KEYS'; --Keys of index separated with comma
    v_pmax_tab_name varchar2(50) := 'PMAX_TBS'; --PMAX/PMIN TBS if you have a PMAX/PMIN
    v_idx_parallel varchar2(1) := 8; -- index parallel sholud be like a table parallel. default it's 1
    p_debug_mode boolean := false;
BEGIN
  v_sql := '';
  
  -- Index partition name and table partition name is equal, but TBS postfix is a little bit different 
  -- That's why i preapare an index TBS name depends on table TBS name
  
  for cur in (
    SELECT PARTITION_NAME, REPLACE(TABLESPACE_NAME,'_D','_I') as TABLESPACE_NAME --if name complex use REGEXP_REPLACE(TABLESPACE_NAME,'_D$','_I')
    FROM all_tab_partitions
    WHERE TABLE_OWNER = v_tab_owner AND TABLE_NAME = v_tab_name
    ORDER BY PARTITION_POSITION
  )
    LOOP
        IF cur.PARTITION_NAME <>'PMAX' AND cur.PARTITION_NAME <> 'PMIN'
            THEN v_sql :=  v_sql || ' PARTITION '|| cur.PARTITION_NAME ||  ' TABLESPACE ' || cur.TABLESPACE_NAME || ',' ||chr(13);
            ELSE v_sql :=  v_sql || ' PARTITION '|| cur.PARTITION_NAME ||  ' TABLESPACE ' || cur.TABLESPACE_NAME ||chr(13);
        END IF;
    END LOOP;
    
    v_sql := 'CREATE UNIQUE INDEX ' || v_tab_owner || '.' || v_tab_name || '_PK'||chr(13)||
           '    ON ' || v_tab_owner || '.' || v_tab_name || '(' || v_key_columns || ')'||chr(13)||
           '    TABLESPACE ' || v_pmax_tab_name ||chr(13)|| --all this code was for this part
           '    LOCAL (' ||chr(13)|| v_sql || ')'||chr(13)||
           '    PARALLEL ' || v_idx_parallel;
	 
	if not p_debug_mode
		then execute immediate v_sql;
		else dbms_output.put_line(v_sql); -- buffer might be not ready to show you all query, that's why you need to purge or limit the cursor query. Example: on partition position (-10 from the end);
	end if;
END;
/
