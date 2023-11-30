import datetime as dt
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.dagrun_operator import TriggerDagRunOperator
from .MySqlToPostgreOperator import MySqlToPostgreOperator

dag = DAG(
    dag_id="MySQltoPostgresDAG",
    start_date=dt.datetime(2023, 5, 21),
    catchup=False,
    schedule_interval=None,
)

start = DummyOperator(task_id='start', dag=dag)

MigrateCustomersData = MySqlToPostgreOperator(
    task_id="MigrateCustomersData",
    sql="select * from db.customer",
    mysql_conn_id='mysql-source',
    postgres_conn_id='postgresql-stg',
    target_table=f'"STG".customer',
    dag=dag,
)

MigrateSalesorderData = MySqlToPostgreOperator(
    task_id="MigrateSalesorderData",
    sql="select * from db.salesorder",
    mysql_conn_id='mysql-source',
    postgres_conn_id='postgresql-stg',
    target_table=f'"STG".salesorder',
    dag=dag,
)

MigrateSalesorderitemData = MySqlToPostgreOperator(
    task_id="MigrateSalesorderitemData",
    sql="select * from db.salesorderitem",
    mysql_conn_id='mysql-source',
    postgres_conn_id='postgresql-stg',
    target_table=f'"STG".salesorderitem',
    dag=dag,
)

truncate_STG_customer = PostgresOperator(
    task_id='truncate_customer_task',
    sql='TRUNCATE TABLE "STG".customer',
    postgres_conn_id = 'postgresql-stg',
    autocommit=True,
    dag=dag
)

truncate_STG_salesorder = PostgresOperator(
    task_id='truncate_salesorder_task',
    sql='TRUNCATE TABLE "STG".salesorder',
    postgres_conn_id = 'postgresql-stg',
    autocommit=True,
    dag=dag
)

truncate_STG_salesorderitem = PostgresOperator(
    task_id='truncate_salesorderitem_task',
    sql='TRUNCATE TABLE "STG".salesorderitem',
    postgres_conn_id = 'postgresql-stg',
    autocommit=True,
    dag=dag
)

end = DummyOperator(task_id='end', dag=dag)

trigger_insert_data_to_data_layer = TriggerDagRunOperator(
    task_id='insert_data_to_data_layer',
    trigger_dag_id='STGtoDM_DATA',
    dag=dag
)


start >> truncate_STG_customer >> MigrateCustomersData >> end 
start >> truncate_STG_salesorder >> MigrateSalesorderData >> end
start >> truncate_STG_salesorderitem >> MigrateSalesorderitemData >> end
end >> trigger_insert_data_to_data_layer