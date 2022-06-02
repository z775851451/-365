#去除退货单号
SELECT 
-- SUM(`下单数量`), SUM(`下单数量`*`标价`)
`子单原始单号`,
-- `下单数量`,
-- `标价`,`下单数量`*`标价`,
`交易时间`,`订单状态`
FROM `旺店通` 
WHERE `店铺` LIKE '%京喜%'
AND `交易时间` BETWEEN '2021-10-01'AND'2021-11-01'
AND `订单状态` IN("已发货","已完成")
AND `订单类型` = "网店销售"
AND `子单原始单号` NOT LIKE "%TCM%"
AND (`子单原始单号` NOT IN(
		#退货单号
			SELECT 
			jd.`客户订单号`
			FROM (SELECT DISTINCT(退货单号),`采购单号` FROM `京东退货单`) jd_th
			LEFT JOIN `京东` jd
			ON jd_th.`采购单号` = jd.`采购单号`
			WHERE jd.`客户订单号` != ''
			AND `下单时间` BETWEEN '2021-10-01'AND'2021-11-01'
			)
AND `子单原始单号` NOT IN(
-- 京东平台数据，去除有退货单号&订单状态为删除的
	SELECT 客户订单号 FROM `京东`
	WHERE (`退货单号` != '' OR `订单状态` = "删除")
	AND `下单时间` BETWEEN '2021-10-01'AND'2021-11-01'
	))



#核对 单量12594------------------------------------------------------------------------------------------
SELECT-- *
wdt.`店铺`,
wdt.`子单原始单号`,
wdt.`订单状态`,
wdt.`订单类型`,
wdt.`仓库`,
wdt.`交易时间`,
wdt.`下单数量`,
wdt.规格名称,
(CASE 
	WHEN wdt.`店铺` = "世翔京喜自营店(京喜)" THEN jd.`采购价` 
	-- 苏宁时间小于12-01的使用苏宁价格，否则用分摊后总价
	WHEN wdt.`店铺` LIKE "%苏宁%" AND wdt.`交易时间` < '2022-01-01' THEN sn.`价格` 
	ELSE wdt.`分摊后总价`
	END ) as 销售价格,
-- jd.`采购价` 销售价格,
wdt.`分摊后总价`,
zclsz.*,
(CASE WHEN wdt.`店铺` = "世翔京喜自营店(京喜)"  THEN vc.结算日期 WHEN wdt.`店铺` LIKE "%苏宁%" THEN  sn_hk.`回款日期` END ) as 结算日期,
-- vc.结算日期,
sn_hk.`回款日期`,
vc.`结算单号`
,SUBSTRING(wdt.`交易时间`,1,7) as 年月
,wlf.每单费用 as 物流费
-- ,wlf.合计/wlf.销售数量 as 物流费
-- ,(CASE WHEN wdt.`店铺`=wlf.店铺 AND wlf.月份 = SUBSTRING(wdt.`交易时间`,1,7) THEN wlf.合计/2 ELSE 0  END) as test
--  SUM(wdt.`下单数量`) 下单总数, SUM(jd.`采购价`*wdt.`下单数量`) 销售价总数, SUM(zclsz.采购价*wdt.`下单数量`) 采购价总数,SUM(jd.`采购价`*wdt.`下单数量`)-SUM(zclsz.采购价*wdt.`下单数量`) 毛利
FROM
	`旺店通` wdt
	LEFT JOIN (
	SELECT
		`原始单号`,
		`商家编码`,
		`订单类型`,
		`单据类型`,
		`规格名称`,
		SUBSTRING( `小柚订单编码`, 1, 10 ) AS 小柚订单编码 
	FROM
		`小柚旺店通销售管理` 
	WHERE
		`订单类型` = '网店销售' 
		AND `单据类型` = '销售订单' 
	) AS xywdt ON wdt.`子单原始单号` = xywdt.`原始单号` AND wdt.`商家编码` = xywdt.`商家编码`
	LEFT JOIN ( SELECT `单号`, `批次号`, `物料号` FROM `自采销售单流水账` WHERE `单据类型` = '自采销售单' ) AS xyzcd ON xywdt.`小柚订单编码` = xyzcd.`单号` 
	AND wdt.`商家编码` = xyzcd.`物料号`
	LEFT JOIN (
	SELECT
		`批次号`,
		`物料号`,
		MAX( `采购价` ) 采购价,
		MAX( `创建时间` ) 创建时间,
		`单据类型` 
	FROM
		`自采单流水账` 
	WHERE
		`单据类型` = '自采单' 
	GROUP BY
		`批次号`,
		`物料号` 
	) AS zclsz ON wdt.`商家编码` = zclsz.`物料号` 
	AND zclsz.`批次号` = xyzcd.`批次号`
	LEFT JOIN `京东` AS jd ON jd.`客户订单号` = wdt.`子单原始单号`
	LEFT JOIN `苏宁报表` AS sn ON sn.`订单编号` = wdt.`子单原始单号`  
	LEFT JOIN `vc结算单` as vc ON vc.`客户订单号` = wdt.`子单原始单号`
	LEFT JOIN 苏宁回款时间 as sn_hk ON sn_hk.`订单日期` = SUBSTRING(wdt.`交易时间`,1,7) AND sn_hk.店铺 = wdt.`店铺`
	LEFT JOIN 物流费 as wlf
	ON wlf.店铺 = wdt.`店铺` AND wlf.月份 = SUBSTRING(wdt.`交易时间`,1,7)
WHERE
	(wdt.`子单原始单号` IN ( SELECT `子单原始单号` FROM `京东单号-去除退货保留日期` ) OR wdt.`子单原始单号` IN(SELECT * FROM `苏宁单号-仅平台单`)  
		OR wdt.`子单原始单号` IN(
			-- 12月没有的苏宁订单
				SELECT `子单原始单号` FROM  旺店通 wdt 
				WHERE wdt.`交易时间` BETWEEN '2021-12-01' 
				AND (SELECT MAX(`交易时间`) FROM `旺店通`) 
				AND wdt.`店铺` LIKE "%苏宁%"  
				AND wdt.`规格名称` NOT LIKE "%充电器%"
				AND wdt.`订单类型` = "网店销售"
				AND wdt.订单状态 in("已完成")
		)
		)
	AND wdt.`交易时间` BETWEEN '2021-09-01' AND (SELECT MAX(`交易时间`) FROM `旺店通`) -- a
-- 	AND wdt.`交易时间` BETWEEN '2021-09-01' AND '2021-10-01' -- a
	AND wdt.`订单类型` = "网店销售"
-- 	AND wdt.`店铺` LIKE "%苏宁%" -- a
	AND wdt.`规格名称` NOT LIKE "%充电器%"
	GROUP BY wdt.`子单原始单号`,wdt.`规格名称`
	
	
	
	
	SELECT * FROM 旺店通 wdt
	LEFT JOIN `苏宁报表` AS sn ON sn.`订单编号` = wdt.`子单原始单号`  
	WHERE wdt.`子单原始单号` IN(SELECT * FROM `苏宁单号-仅平台单` )
	AND wdt.`交易时间` BETWEEN '2021-09-01' AND '2021-10-01' -- a
	AND wdt.`订单类型` = "网店销售"
-- 	AND wdt.`店铺` LIKE "%苏宁小米%" -- a
	AND wdt.`规格名称` NOT LIKE "%充电器%"
	
	
	
	
	
	
	
	
	UNION
	
	-- 5821
	
	SELECT * FROM 旺店通 wdt
	WHERE
	(wdt.`子单原始单号` IN ( SELECT `子单原始单号` FROM `京东单号-去除退货保留日期` ) OR wdt.`子单原始单号` IN(SELECT * FROM `苏宁单号-仅平台单` ))
	AND wdt.`订单类型` = "网店销售"
	AND wdt.`交易时间` BETWEEN '2021-12-01' AND (SELECT MAX(`交易时间`) FROM `旺店通`)
	AND wdt.`店铺` LIKE "%世翔京喜自营店(京喜)%"
	AND wdt.`规格名称` NOT LIKE "%充电器%"
	
	
	
SELECT (CASE WHEN `店铺`="世翔京喜自营店(京喜)" THEN 1 ELSE 0 END) as test
FROM 物流费
	

SELECT * FROM 物流费
WHERE `店铺` = '世翔京喜自营店(京喜)'
AND 月份 = '2021-11'


(SELECT COUNT(*) as 当月下单数量 FROM `京东单号-去除退货保留日期`
WHERE SUBSTRING(`交易时间`,1,7) = '2021-10')

-- AND xyzcd.`单据类型` = '自采销售单' 


-- ---------------------------------------------------------------------------------------------------------
-- 验证


-- 正确:12568行 `小柚旺店通销售管理` 13284\12607

SELECT 
-- *
xywdt.`小柚订单编码`,xywdt.`商家编码`,jd_dh.`子单原始单号`,jd_dh.`交易时间`
,zcxs.`批次号`
-- DISTINCT(`原始单号`)
FROM `小柚旺店通销售管理` as xywdt
RIGHT JOIN `京东单号-去除退货保留日期` as jd_dh
ON jd_dh.`子单原始单号` = xywdt.`原始单号`
LEFT JOIN `自采销售单流水账` as zcxs
ON zcxs.`单号` = xywdt.`小柚订单编码` AND zcxs.`物料号` = xywdt.`商家编码`
LEFT JOIN `自采单流水账` as zclsz
ON zcxs.批次号 = zclsz.批次号 AND zcxs.物料号 = zclsz.物料号

WHERE jd_dh.`交易时间`  BETWEEN '2021-10-01'AND'2021-11-01'

AND xywdt.`订单类型` = '网店销售' 
AND xywdt.`单据类型` = '销售订单' 
AND zclsz.`单据类型` = '自采单' 
AND `店铺名称` = "世翔京喜自营店(京喜)"
AND xywdt.`原始单号` != ""







-- 去重前:2735 去重后:2585
-- 自采单重复单号
SELECT  `批次号`,`物料号`,COUNT(*) c FROM `自采单流水账`
WHERE `单据类型` = "自采单"
GROUP BY `批次号`,`物料号`
HAVING c > 1








# 
SELECT * FROM `京东`
where `客户订单号` NOT IN(SELECT `客户订单号` FROM `京东` WHERE `品牌` LIKE '%Apple%' )
AND `客户订单号` NOT IN(SELECT `客户订单号` FROM `京东` WHERE `品牌` LIKE '%小米（MI）%' )





SELECT COUNT(`子单原始单号`) FROM `旺店通`
WHERE `店铺` LIKE '%京喜%'
AND `交易时间` BETWEEN '2021-10-01'AND'2021-11-01'




SELECT * FROM `京东`
WHERE `订单状态` = "删除"









SELECT 客户订单号 FROM `京东`
WHERE `退货单号` != ''
AND `下单时间` BETWEEN '2021-10-01'AND'2021-11-01'
UNION
SELECT 
jd.`客户订单号`
FROM (SELECT DISTINCT(退货单号),`采购单号` FROM `京东退货单`) jd_th
LEFT JOIN `京东` jd
ON jd_th.`采购单号` = jd.`采购单号`
WHERE jd.`客户订单号` != ''
AND `下单时间` BETWEEN '2021-10-01'AND'2021-11-01'


