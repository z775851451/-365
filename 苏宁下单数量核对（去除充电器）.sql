SELECT * FROM
(select *,wdtsl-snsl as cha 
FROM
(SELECT SUM(wdt.`下单数量`) as wdtsl,wdt.`子单原始单号` FROM `旺店通` wdt
LEFT JOIN (SELECT DISTINCT(`订单编号`) as 订单编号 FROM `苏宁报表`) sn
ON sn.`订单编号` = wdt.`子单原始单号`
WHERE sn.`订单编号` != ""
AND wdt.`店铺`  = "苏宁荣耀旗舰店" 
-- 充电器编码
-- AND wdt.`商家编码` NOT IN("1239185","1245647")
AND wdt.`规格名称` NOT LIKE "%充电器%" 
GROUP BY wdt.`子单原始单号`) as a
,
(SELECT SUM(购买数量) as snsl,`订单编号` FROM `苏宁报表` sn
WHERE sn.`店铺`  = "苏宁荣耀旗舰店"
GROUP BY sn.`订单编号`)as b
WHERE a.`子单原始单号` = b.`订单编号`)as c
WHERE c.cha != 0

#销量求和
SELECT *,COUNT(`snsl`),COUNT(`wdtsl`) FROM
(select *,wdtsl-snsl as cha 
FROM
(SELECT SUM(wdt.`下单数量`) as wdtsl,wdt.`子单原始单号` FROM `旺店通` wdt
LEFT JOIN (SELECT DISTINCT(`订单编号`) as 订单编号 FROM `苏宁报表`) sn
ON sn.`订单编号` = wdt.`子单原始单号`
WHERE sn.`订单编号` != ""
AND wdt.`店铺` LIKE "%苏宁%" 
-- 充电器编码
-- AND wdt.`商家编码` NOT IN("1239185","1245647")
AND wdt.`规格名称` NOT LIKE "%充电器%" 
GROUP BY wdt.`子单原始单号`) as a
,
(SELECT SUM(购买数量) as snsl,`订单编号` FROM `苏宁报表` sn
WHERE sn.`店铺` LIKE "%苏宁%" 
GROUP BY sn.`订单编号`)as b
WHERE a.`子单原始单号` = b.`订单编号`)as c
-- AND wdt.`交易时间` BETWEEN BETWEEN '2021-09-01'AND'2021-10-01'



#苏宁 wdt 单数正确结果 - 已经去重
SELECT 
	DISTINCT(wdt.`子单原始单号`) as 子单原始单号
	,`规格名称`
-- 	,
-- 	SUM(wdt.`实发数量`)
FROM `旺店通` wdt
LEFT JOIN (SELECT DISTINCT(`订单编号`) as 订单编号 FROM `苏宁报表` WHERE `订单状态（头状态）` != "交易关闭" ) sn
ON sn.`订单编号` = wdt.`子单原始单号`
WHERE sn.`订单编号` != ""
AND wdt.`店铺` LIKE "%苏宁小米%" 
AND wdt.`交易时间` BETWEEN '2021-09-01'AND'2021-10-01'
AND wdt.`规格名称` NOT LIKE "%充电器%" 
AND wdt.订单状态 in ('已发货','已完成')
AND wdt.`订单类型` = "网店销售"




SELECT SUM(`购买数量`) FROM `苏宁报表`
WHERE `订单下单时间` BETWEEN '2021-11-01'AND'2021-12-01'
AND `店铺` = '苏宁荣耀旗舰店'

-- 
-- SELECT DISTINCT(wdt.`子单原始单号`) FROM `旺店通` wdt
-- RIGHT JOIN `苏宁报表` sn 
-- ON wdt.`子单原始单号` = sn.`订单编号`
-- WHERE wdt.`店铺` LIKE "%苏宁荣耀%" 
-- AND wdt.`交易时间` BETWEEN '2021-11-01'AND'2021-12-01'
-- AND wdt.`订单类型` = "网店销售"
-- 

