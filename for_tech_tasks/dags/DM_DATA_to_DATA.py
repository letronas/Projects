import datetime as dt
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.python_operator import PythonOperator
from airflow.hooks.postgres_hook import PostgresHook


def entry_func_sales_order_item_flat():
    hook = PostgresHook('postgresql-stg')
    conn = hook.get_conn()
    target_table = '"DATA".sales_order_item_flat'
    with conn.cursor() as cursor_src:
        cursor_src.execute("""
                            select
                            soi.item_id
                            , coalesce(so.id, soi.order_id) as order_id
                            , so.order_number
                            , so.created_at as order_created_at
                            , so.order_total
                            , so.total_qty_ordered
                            , coalesce(cust.id, so.customer_id) as customer_id
                            , cust.first_name as customer_name
                            , cust.gender as customer_gender
                            , cust.email as customer_email
                            , soi.product_id
                            , soi.product_sku
                            , soi.product_name
                            , soi.price as item_price
                            , soi.qty_ordered as item_qty_order
                            --, soi.item_unit_total doesn't exist yet in data
                            from "DM_DATA".salesorderitem soi
                            full join "DM_DATA".salesorder so
                                on so.id = soi.order_id
                            full join "DM_DATA".customer cust
                                on cust.id = so.customer_id
                        """)
        
        # Dynamic columns for dict + mask in insert
        future_dict_keys = [x[0] for x in cursor_src.description]
        columns_for_query = ', '.join(future_dict_keys)
        placeholders = ', '.join(['%({})s'.format(key) for key in future_dict_keys])
        with conn.cursor() as cursor_tgt:
            for row in cursor_src.fetchall():
                values = dict(zip(future_dict_keys, row))
                sql = f"INSERT INTO {target_table} ({columns_for_query}) VALUES ({placeholders})"     # self.target_table
                cursor_tgt.execute(sql, values)
            conn.commit()
            
			
			
dag = DAG(
    dag_id="DM_DATA_to_DATA",
    start_date=dt.datetime(2023, 5, 21),
    catchup=False,
    schedule_interval=None,
)

start = DummyOperator(task_id='start', dag=dag)

truncate_data = PostgresOperator(
    task_id='truncate_data',
    sql='TRUNCATE TABLE "DATA".sales_order_item_flat',
    postgres_conn_id = 'postgresql-stg',
    autocommit=True,
    dag=dag
)

insert_data_task = PythonOperator(
    task_id='insert_data_task',
    python_callable=entry_func_sales_order_item_flat,
    dag=dag
)


end = DummyOperator(task_id='end', dag=dag)

start >> truncate_data >> insert_data_task >> end