from airflow.models.baseoperator import BaseOperator
from airflow.hooks.mysql_hook import MySqlHook
from airflow.hooks.postgres_hook import PostgresHook


class MySqlToPostgreOperator(BaseOperator):
    
    def __init__(self,
                 sql=None,
                 target_table=None,
                 mysql_conn_id='mysql-source',
                 postgres_conn_id='postgresql-stg',
                 *args,
                 **kwargs):
        super().__init__(*args, **kwargs)
        self.sql = sql
        self.target_table = target_table
        self.mysql_conn_id = mysql_conn_id
        self.postgres_conn_id = postgres_conn_id
        self.charset = 'utf8'
    
    def execute(self, context):        
        source = MySqlHook(self.mysql_conn_id, charset='utf8')
        print('Source hook created')
        target = PostgresHook(self.postgres_conn_id, client_encoding ='utf8')
        print('Target hook created')       
        
        # For fetching rows from source
        conn_src = source.get_conn()
        with conn_src.cursor() as cursor_src:
            
            # Conn for tgt
            conn_tgt = target.get_conn()
            
            # Get cursor to source data
            cursor_src.execute(self.sql)
            
            # Dynamic columns for dict + mask in insert
            future_dict_keys = [x[0] for x in cursor_src.description]
            columns_for_query = ', '.join(future_dict_keys)
            # This is for passing arabic string in correct way with this version of lib, but it doesn't help
            placeholders = ', '.join(['%({})s'.format(key) for key in future_dict_keys])
            
            with conn_tgt.cursor() as cursor_tgt:
                for row in cursor_src.fetchall():
                    values = dict(zip(future_dict_keys, row))
                    sql = f"INSERT INTO {self.target_table} ({columns_for_query}) VALUES ({placeholders})"     # self.target_table

                    cursor_tgt.execute(sql, values)
                conn_tgt.commit()
                
            """
            target_fields = [x[0] for x in cursor.description]
            rows = cursor.fetchall()
            print('All rows are fetched')
            
            target.insert_rows(table=self.target_table,
                               rows=rows,
                               target_fields=target_fields,
                               commit_every=1000000,
                               replace=False)
            """
        print('Inserts are done')
            
        conn_src.close()
        conn_tgt.close()