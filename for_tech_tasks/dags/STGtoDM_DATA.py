import datetime as dt
import pendulum
import re
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dagrun_operator import TriggerDagRunOperator
from airflow.hooks.postgres_hook import PostgresHook

# entry_func_customer logic
def is_valid_emaild(email: str):
    pattern = r'^[\w\.-]+@[\w\.-]+\.\w+$'
    return re.match(pattern, email) is not None


def normalize_email(email: str):
    email = email.strip().lower()
    
    # Delete all uncorrect in beginning and in the end
    email = re.sub(r'^[^a-zA-Z0-9_.+-]+|[^a-zA-Z0-9_.+-]+$', '', email)
    
    # Local and domain part
    parts = email.split('@')
    if len(parts) < 2:
        return None
    local_part = parts[0]
    domain_part = '@'.join(parts[1:])
    
    # Works just for this data and actually not the best solution
    domain_part = re.sub(r'@', '_', domain_part, count=len(parts) - 2)
    
    # Delete al incorrect in both parts
    local_part = re.sub(r'[^a-zA-Z0-9_.+-]', '', local_part)
    domain_part = re.sub(r'[^a-zA-Z0-9.-]', '', domain_part)
    
    # Get it back to email
    normalized_email = f"{local_part}@{domain_part}"
    
    return normalized_email


def entry_func_customer():
    hook = PostgresHook('postgresql-stg')
    conn = hook.get_conn()

    with conn.cursor() as cursor_src:
        cursor_src.execute("""
                            SELECT 
                            trim(id)::bigint as id 
                            , trim(first_name) as first_name 
                            , trim(last_name) as last_name 
                            , trim(gender) as gender
                            , trim(email) as email 
                            , trim(billing_address) as billing_address 
                            , trim(shipping_address) as shipping_address 
                            FROM "STG".customer
                            """)
        with conn.cursor() as cursor_tgt:
            for row in cursor_src:
                id, first_name, last_name, gender, email, billing_address, shipping_address = row
                first_name = first_name.replace(u"\xa0", '').strip()
                last_name = last_name.strip()
                
                gender = gender.lower()
                if gender.find('f') != -1 or gender.find('em') != -1:
                    gender = 'Female'
                else:
                    gender = 'Male'
                
                email = email.strip()
                email_validity = is_valid_emaild(email)
                if not is_valid_emaild(email):
                    email = normalize_email(email)
                
                billing_address = billing_address.strip()
                shipping_address = shipping_address.strip()
                
                values = {
                    'id': id,
                    'first_name': first_name,
                    'last_name': last_name,
                    'gender': gender,
                    'email': email,
                    'billing_address': billing_address,
                    'shipping_address': shipping_address
                }
                
                
                sql = """
                    INSERT INTO "DM_DATA".customer (
                        id, first_name, last_name, gender, email,
                        billing_address, shipping_address
                    )
                    VALUES (
                        %(id)s, %(first_name)s, %(last_name)s, %(gender)s, %(email)s,
                        %(billing_address)s, %(shipping_address)s
                    )
                    """
                
                cursor_tgt.execute(sql, values)
            
            conn.commit()
  

# Solution for salesorder

def date_parse(i_date: str):
    if i_date.find("/") == -1:
        i_date = pendulum.parse(i_date)
        return i_date
    else:
        month, day, year = i_date.split("/")
        year, time = year.split(' ')
        
        day = day[:2]
        while day[0] == 0:
            day = day[1:]
        
        month = month[:2]
        while month[0] == 0:
            month = month[1:]
        
        year = year[:4]
        while year[0] == 0:
            year = year[1:]
        
        hour, minute, second = time.split(':')
        
        hour = hour[:2]
        minute = minute[:2]
        second = second[:2]
        
        i_date = pendulum.datetime(int(year), int(month), int(day), int(hour), int(minute),
                                       int(second))
        
        return i_date
        

def entry_func_salesorder():
    hook = PostgresHook('postgresql-stg')
    conn = hook.get_conn()
    
    with conn.cursor() as cursor_src:
        cursor_src.execute("""
                            SELECT 
                            CASE WHEN trim(id) = '' THEN 0 ELSE trim(id)::bigint END AS id
                            ,CASE WHEN trim(customer_id) = '' THEN 0 ELSE trim(customer_id)::bigint end as customer_id
                            ,trim(order_number) as order_number
                            , trim(created_at) as created_at
                            , trim(modified_at) as modified_at
                            , CASE WHEN trim(order_total) = '' THEN 0 ELSE trim(order_total)::numeric end as order_total
                            , CASE WHEN trim(total_qty_ordered) = '' THEN 0 ELSE trim(total_qty_ordered)::bigint end
                            as total_qty_ordered
                            FROM "STG".salesorder 
                            where CASE WHEN id = '' THEN 0 ELSE id::bigint end != 0
                            """)
        with conn.cursor() as cursor_tgt:
            for row in cursor_src:
                id, customer_id, order_number, created_at, modified_at, order_total, total_qty_ordered = row
                
                created_at = date_parse(created_at)
                modified_at = date_parse(modified_at)
                
                values = {
                    'id': id,
                    'customer_id': customer_id,
                    'order_number': order_number,
                    'created_at': created_at,
                    'modified_at': modified_at,
                    'order_total': order_total,
                    'total_qty_ordered': total_qty_ordered
                }
                
                sql = """
                        INSERT INTO "DM_DATA".salesorder (
                            id, customer_id, order_number, created_at, modified_at,
                            order_total, total_qty_ordered
                        )
                        VALUES (
                            %(id)s, %(customer_id)s, %(order_number)s, %(created_at)s, %(modified_at)s,
                            %(order_total)s, %(total_qty_ordered)s
                        )
                        """

                cursor_tgt.execute(sql, values)

            conn.commit()


# Solution for salesorderitem
def entry_func_salesorderitem():
    hook = PostgresHook('postgresql-stg')
    conn = hook.get_conn()
    
    with conn.cursor() as cursor_src:
        cursor_src.execute("""
                            with pre_data as (
                            SELECT DISTINCT
                            CASE WHEN trim(item_id) = '' THEN 0 ELSE trim(item_id)::bigint end as item_id
                            , CASE WHEN trim(order_id) = '' THEN 0 ELSE trim(order_id)::bigint end as order_id
                            , CASE WHEN trim(product_id) = '' THEN 0 ELSE trim(product_id)::bigint end as product_id
                            , trim(product_sku) as product_sku
                            , trim(product_name) as product_name
                            , CASE WHEN trim(qty_ordered) = '' THEN 0 ELSE trim(qty_ordered)::bigint end as qty_ordered
                            , CASE WHEN trim(price) = '' THEN 0 ELSE trim(price)::numeric end as price
                            , CASE WHEN trim(line_total) = '' THEN 0 ELSE trim(line_total)::numeric end as line_total
                            , trim(created_at) as created_at
                            , trim(modified_at) as modified_at
                            FROM "STG".salesorderitem)
                            select * from pre_data
                            """)

        with conn.cursor() as cursor_tgt:
            for row in cursor_src:
                item_id, order_id, product_id, product_sku, \
                product_name, qty_ordered, price, line_total, created_at, modified_at = row
                
                created_at = date_parse(created_at)
                modified_at = date_parse(modified_at)
                
                values = {
                    'item_id': item_id,
                    'order_id': order_id,
                    'product_id': product_id,
                    'product_sku': product_sku,
                    'product_name': product_name,
                    'qty_ordered': qty_ordered,
                    'price': price,
                    'line_total': line_total,
                    'created_at': created_at,
                    'modified_at': modified_at
                }
                sql = """
                    INSERT INTO "DM_DATA".salesorderitem (
                        item_id, order_id, product_id, product_sku, product_name,
                        qty_ordered, price, line_total, created_at, modified_at
                    )
                    VALUES (
                        %(item_id)s, %(order_id)s, %(product_id)s, %(product_sku)s, %(product_name)s,
                        %(qty_ordered)s, %(price)s, %(line_total)s, %(created_at)s, %(modified_at)s
                    )
                """
                cursor_tgt.execute(sql, values)
            
            conn.commit()



dag = DAG(
    dag_id="STGtoDM_DATA",
    start_date=dt.datetime(2023, 5, 21),
    catchup=False,
    schedule_interval=None,
)

start = DummyOperator(task_id='start', dag=dag)

truncate_dm_data_customer = PostgresOperator(
    task_id='truncate_dm_data_customer',
    sql='TRUNCATE TABLE "DM_DATA".customer',
    postgres_conn_id = 'postgresql-stg',
    autocommit=True,
    dag=dag
)

truncate_dm_data_salesorder = PostgresOperator(
    task_id='truncate_dm_data_salesorder',
    sql='TRUNCATE TABLE "DM_DATA".salesorder',
    postgres_conn_id = 'postgresql-stg',
    autocommit=True,
    dag=dag
)

truncate_dm_data_salesorderitem = PostgresOperator(
    task_id='truncate_dm_data_salesorderitem',
    sql='TRUNCATE TABLE "DM_DATA".salesorderitem',
    postgres_conn_id = 'postgresql-stg',
    autocommit=True,
    dag=dag
)

insert_customer_data_task = PythonOperator(
    task_id='insert_customer_data_task',
    python_callable=entry_func_customer,
    dag=dag
)

insert_salesorder_data_task = PythonOperator(
    task_id='insert_salesorder_data_task',
    python_callable=entry_func_salesorder,
    dag=dag
)

insert_salesorderitem_data_task = PythonOperator(
    task_id='insert_salesorderitem_data_task',
    python_callable=entry_func_salesorderitem,
    dag=dag
)

end = DummyOperator(task_id='end', dag=dag)

trigger_insert_data_to_final_data_layer = TriggerDagRunOperator(
    task_id='insert_data_to_final_data_layer',
    trigger_dag_id='DM_DATA_to_DATA',
    dag=dag
)



start >> truncate_dm_data_customer >> insert_customer_data_task >> end
start >> truncate_dm_data_salesorder >> insert_salesorder_data_task >> end
start >> truncate_dm_data_salesorderitem >> insert_salesorderitem_data_task >> end
end >> trigger_insert_data_to_final_data_layer