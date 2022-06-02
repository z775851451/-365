
SELECT 
-- *
-- wdt.`店铺`,wdt.`子单原始单号`,wdt.`订单状态`,wdt.`订单类型`,wdt.`仓库`,wdt.`交易时间`,wdt.`下单数量`,wdt.规格名称,jd.`采购价` 销售价格,zclsz.*
SUM(wdt.`下单数量`) 下单总数, SUM(jd.`采购价`*wdt.`下单数量`) 销售价总数, SUM(zclsz.采购价*wdt.`下单数量`) 采购价总数,SUM(jd.`采购价`*wdt.`下单数量`)-SUM(zclsz.采购价*wdt.`下单数量`) 毛利
FROM `旺店通` wdt
	LEFT JOIN `小柚旺店通销售管理` AS xywdt ON wdt.`子单原始单号` = xywdt.`原始单号`
	LEFT JOIN `自采销售单流水账` AS xyzcd ON xywdt.`小柚订单编码` = xyzcd.`单号` 
	AND wdt.`商家编码` = xyzcd.`物料号`
	
	LEFT JOIN (
		SELECT  `批次号`, `物料号`,MAX(`采购价`) 采购价 ,MAX(`创建时间`) 创建时间,`单据类型` 
		FROM `自采单流水账` WHERE `单据类型` = '自采单' 
		GROUP BY `批次号`, `物料号`
		) AS zclsz ON wdt.`商家编码` = zclsz.`物料号` 
	AND zclsz.`批次号` = xyzcd.`批次号`
	LEFT JOIN `京东` as jd 
	ON jd.`客户订单号` = wdt.`子单原始单号`
	
WHERE	`子单原始单号` IN(SELECT * FROM`京东单号-去除退货与非平台`)

AND `交易时间` BETWEEN '2021-10-01'AND'2021-11-01'
AND wdt.`订单类型` = "网店销售"
AND xywdt.`订单类型` = '网店销售' 
AND xywdt.`单据类型` = '销售订单' 
AND xyzcd.`单据类型` = '自采销售单' 
