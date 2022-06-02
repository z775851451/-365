import numpy as np
import pandas as pd
import os
import openpyxl
import re
import warnings
import time
warnings.filterwarnings("ignore")

print('开始运行,请勿关闭')

print('请确保将数据已放置到excel目录，（4个仓库，1个销售总表）')
print('如要停止运行：ctrl+c')

url = 'excel/'

if '总.xlsx' not in os.listdir(url):
    z = pd.read_csv('./excel/总.csv')
    z.to_excel(url+'总.xlsx',index=False)
    zs = pd.read_excel('./excel/总.xlsx')
else:
    zs = pd.read_excel('./excel/总.xlsx')


# zs = pd.read_excel('./excel/总.xlsx')


世翔手机专营店 = zs.query("店铺 == '世翔手机专营店'")
江格手机拼购店01 = zs.query("店铺 == '江格手机拼购店01'")
常熟优友 = zs.query("店铺 == '常熟优友金服供应商01'")
苏宁 = zs.query("店铺 == '苏宁荣耀旗舰店' or 店铺 == '苏宁小米旗舰店' or 店铺 == '苏宁华为旗舰店' or 店铺 == '苏宁苹果旗舰店' or 店铺 == '世翔京喜自营店(京喜)'")


print('正在保存销售表...........')

d = ['.','.','.','.','.','.','.']

for i in d:
    print(i)

世翔手机专营店.to_excel('./excel/世翔手机专营店.xlsx',index=False)
江格手机拼购店01.to_excel('./excel/江格手机拼购店01.xlsx',index=False)
常熟优友.to_excel('./excel/常熟优友.xlsx',index=False)
苏宁.to_excel('./excel/苏宁.xlsx',index=False)
print('销售表已保存')

dir_li = os.listdir(url)



dir_dict = {
            "世翔拼多多":["世翔手机"],
            "江格电商":["江格手机"],
            "常熟金服供应链":["常熟优友"],
            "世翔电商":["世翔惊喜",'苏宁']
            }

new_dict = {}
print('检测到excel目录下有以下文件：',dir_li)


def color_negative_red(val):
    if val >= 7 and val <= 20:
        color = 'green'
    elif val < 7:
        color = 'yellow'
    elif val > 20:
        color = 'red'
    else:
        color = ''
    return 'background-color: %s' % color


for i,j in dir_dict.items():
    for _ in dir_li:
        if _.startswith(i):
            new_dict[_] = []
            for a in j:
                for a_ in dir_li:
                    if a_.startswith(a):
                        new_dict[_].append(a_)
                        
# -*- coding:utf-8 -*-
ename = '库存/告警.xlsx'
li = []
with pd.ExcelWriter(ename,engine='openpyxl') as writer:
    for i,j in new_dict.items():
        a = 0
        for _ in j:
            sxpddc = pd.read_excel('./excel/'+i,usecols=['商家编码','规格名称','库存'])
            sxpddd = pd.read_excel('./excel/'+j[a],usecols=['商家编码','货品名称','规格名称','实发数量'])
            
            a += 1
            print(i,j)
            if sxpddd.empty:
                continue
            
            sxpdddgr = sxpddd.groupby(['商家编码','规格名称']).sum()
            sxpdddgr = sxpdddgr.merge(sxpddc,how='right',on='商家编码').fillna(0)
            zhou = round(sxpdddgr['实发数量']/30*7)
            banyue = round(sxpdddgr['实发数量']/30*15)
            yujing = round(sxpdddgr['库存']/(sxpdddgr['实发数量']/30),0)
            sxpdddgr = sxpdddgr.assign(七日销售数量 = zhou,十五日销售数量 = banyue,预警天数 = yujing)
            
            sxpdddgr = sxpdddgr.assign(颜色1 = sxpdddgr.规格名称.map(lambda x:re.findall("[^/]+(?!.*/)",x)[0]))
            
            sxpdddgr.insert(3,'颜色',sxpdddgr.颜色1)
            sxpdddgr = sxpdddgr.drop(columns='颜色1')
            
            sxpdddgr['预警天数'][np.isinf(sxpdddgr['预警天数'])] = np.nan
            sxpdddgr.rename(columns={'实发数量':'30天销售数量'},inplace=True)
            
            sxpdddgr = sxpdddgr.assign(品牌 = sxpdddgr.规格名称.map(lambda x:re.findall('^(U_|U|I|I_)([\u4e00-\u9fa5a-zA-Z0-9]{1,})',x)[0][1]))
            
            sxpdddgr.sort_values('规格名称')
            
            sxpdddgr.to_excel(writer,sheet_name=i,index=False)
            li.append(sxpdddgr)
    zong = pd.concat(li)
    zong.to_excel(writer,sheet_name='总计',index=False)



print('正在生成库存预警.xlsx')
import datetime 
dt = str(datetime.date.today())

wb = openpyxl.load_workbook(ename)
sheet_names = wb.sheetnames
excelname = '库存/'+dt+'库存预警.xlsx'
print(excelname)
with pd.ExcelWriter(excelname,engine='openpyxl') as writer:
    for i in sheet_names:
        df = pd.read_excel(ename,sheet_name=i)
        df = df.style.applymap(color_negative_red, subset=['预警天数'])
        df.to_excel(writer,sheet_name=i,index=False)

# writer.save()
# writer.close()
#
print('已保存,运行完成')
