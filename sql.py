# import os
# from sqlalchemy import create_engine
# import pandas as pd
# import pymysql
# import yaml
# from tqdm import tqdm
# from time import sleep


import os
from sqlalchemy import create_engine
import pandas as pd
import pymysql
import yaml
from tqdm import tqdm
from time import sleep

# print('正在加载配置文件......')
# def config_dp():
#     # print('正在加载配置文件......')
#     try:
#         with open('config.yml', 'r', encoding='utf-8') as f:
#             result = yaml.load(f.read(), Loader=yaml.FullLoader)
#         return result
#     except:
#         print('缺少配置文件:config.yml,或检查是否设置有误')
#         return None

# path = config_dp()['path']
# con = config_dp()
# database : config_dp()['database_c']['database']
# host = config_dp()['database_c']['host']
# port = config_dp()['database_c']['port']
# user = config_dp()['database_c']['user']
# password = config_dp()['database_c']['password']
# database = config_dp()['database_c']['database']
# charset = config_dp()['database_c']['charset']
# query_max_date = config_dp()['select']
# fugai = config_dp()['fugai']
# engine = create_engine(f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}?charset={charset}")
# # query_max_date
# # query_max_date['vc结算单']['select max(结算日期) from vc结算单']


# #读取数据文件
# def read_df(path,file_name,usecols=None):
#     df = pd.read_excel(path+file_name,usecols = usecols)
#     return df

# #数据库添加数据 重新添加为：replace
# # truncate table ``
# def sql_insert(df,table_name,fun='append'):
#     df.to_sql(table_name, engine, schema=database, if_exists=fun, index=False,
#                 chunksize=None, dtype=None)
    
# #读取数据库 tables_name
# def tables_list(database,sql):
#     db = pymysql.connect(host=host,port=port,user=user,password=password,database=database,charset=charset)

#     #利用db方法创建游标对象
#     cur = db.cursor()
    
#     #利用游标对象execute()方法执行SQL命令
#     cur.execute(sql)
    
#     #fetchone()方法获取返回对象的单条数据 fetchall 方法获取返回对象的所有数据
#     data = cur.fetchall()
    
#     #关闭数据库连接
#     db.close()
#     return data

# k_n = []
# v_n = []
# s = []
# for key,value in query_max_date.items():
#     for k,v in value.items():
#         date = tables_list(database,k)[0][0]
#         s.append(str(date))
#         k_n.append(key)
#         v_n.append(str(v))
# df_max = pd.DataFrame(data=[k_n,v_n,s],index = ['表','链接','最大日期']).T

# df_max.to_html('最大日期.html')

# if input('导入文件后输入’YES‘继续') == "YES":
#     file_name = os.listdir(path)
#     print(f'路径：{path}\n文件列表:\n'+'\n'.join(file_name))

#     table_names = []
#     s_count = []
#     e_count = []

#     for key,value in tqdm(con['re'].items()):
#         start = tables_list(database,"select count(*) from "+key)[0][0]
#         sleep(0.05)
#         for k,y in value.items():
#             try:
#                 # df = read_df(path,k+'.xlsx',y)
#                 df = read_df(path,k,y)
#                 # sql_insert(df,key)
#                 if key in fugai:
#                     #清空
#                     # truncate table ``
#                     tables_list(database,"truncate table "+key)
#                     sql_insert(df,key)
#                 else:
#                     sql_insert(df,key)
#                 table_names.append(key)
#                 s_count.append(start)
#                 end = tables_list(database,"select count(*) from "+key)[0][0]
#                 e_count.append(end)
#             except:
#                 # df = read_df(path,k+'.xls',y)
#                 print("没有文件"+k+'请检查文件是否存在，或‘后缀名’不正确')
#                 break
            
#     relult = pd.DataFrame(data=[e_count,s_count],columns=table_names,index = ['添加后','添加前']).T
#     relult = relult.assign(本次添加条数=relult.添加后-relult.添加前)
#     relult.to_html('结果.html')
# else:
#     pass

print('正在加载配置文件......')
def config_dp():
    # print('正在加载配置文件......')
    try:
        with open('config.yml', 'r', encoding='utf-8') as f:
            result = yaml.load(f.read(), Loader=yaml.FullLoader)
        return result
    except:
        print('缺少配置文件:config.yml,或检查是否设置有误')
        return None

path = config_dp()['path']
con = config_dp()
database : config_dp()['database_c']['database']
host = config_dp()['database_c']['host']
port = config_dp()['database_c']['port']
user = config_dp()['database_c']['user']
password = config_dp()['database_c']['password']
database = config_dp()['database_c']['database']
charset = config_dp()['database_c']['charset']
query_max_date = config_dp()['select']
fugai = config_dp()['fugai']
engine = create_engine(f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}?charset={charset}")
# query_max_date
# query_max_date['vc结算单']['select max(结算日期) from vc结算单']


#读取数据文件
def read_df(path,file_name,usecols=None):
    df = pd.read_excel(path+file_name,usecols = usecols)
    return df

#数据库添加数据 重新添加为：replace
# truncate table ``
def sql_insert(df,table_name,fun='append'):
    df.to_sql(table_name, engine, schema=database, if_exists=fun, index=False,
                chunksize=None, dtype=None)
    
#读取数据库 tables_name
def tables_list(database,sql):
    db = pymysql.connect(host=host,port=port,user=user,password=password,database=database,charset=charset)

    #利用db方法创建游标对象
    cur = db.cursor()
    
    #利用游标对象execute()方法执行SQL命令
    cur.execute(sql)
    
    #fetchone()方法获取返回对象的单条数据 fetchall 方法获取返回对象的所有数据
    data = cur.fetchall()
    
    #关闭数据库连接
    db.close()
    return data

k_n = []
v_n = []
s = []
for key,value in query_max_date.items():
    for k,v in value.items():
        date = tables_list(database,k)[0][0]
        s.append(str(date))
        k_n.append(key)
        v_n.append(str(v))
df_max = pd.DataFrame(data=[k_n,v_n,s],index = ['表','链接','最大日期']).T

df_max.to_html('最大日期.html')

if input('导入文件后输入’YES‘继续') == "YES":
    file_name = os.listdir(path)
    print(f'路径：{path}\n文件列表:\n'+'\n'.join(file_name))

    table_names = []
    s_count = []
    e_count = []

    for key,value in tqdm(con['re'].items()):
        start = tables_list(database,"select count(*) from "+key)[0][0]
        sleep(0.05)
        for k,y in value.items():
            try:
                # df = read_df(path,k+'.xlsx',y)
                df = read_df(path,k,y)
                # sql_insert(df,key)
                if key in fugai:
                    #清空
                    # truncate table ``
                    tables_list(database,"truncate table "+key)
                    sql_insert(df,key)
                else:
                    sql_insert(df,key)
                table_names.append(key)
                s_count.append(start)
                end = tables_list(database,"select count(*) from "+key)[0][0]
                e_count.append(end)
            except:
                # df = read_df(path,k+'.xls',y)
                print("没有文件"+k+'请检查文件是否存在，或‘后缀名’不正确')
                break
            
    relult = pd.DataFrame(data=[e_count,s_count],columns=table_names,index = ['添加后','添加前']).T
    relult = relult.assign(本次添加条数=relult.添加后-relult.添加前)
    relult.to_html('结果.html')
else:
    pass


