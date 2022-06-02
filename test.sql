SET @day_s = '2021-09-01';
SET @day_d = '2021-09-30';-- SELECT
-- SUM(a.a),SUM(a.`实发数量`),SUM(a.`销售总额`)
-- FROM(
SELECT
	wdt.`订单编号`,
	wdt.`店铺`,
	wdt.`商家编码`,
	wdt.`规格名称`,
	wdt.`订单类型`,
	wdt.`子单原始单号`,
	wdt.`交易时间`,
	wdt.`分摊后总价`,
	wdt.`实发数量`,
	wdt.`标价`,
	wdt.`实发数量` * wdt.`标价` AS 销售总额,
	xywdt.`小柚订单编码`,
	xyzcd.`批次号`,
	zclsz.`采购价`,
	zclsz.`创建时间`,
	jd.`客户订单号`,
	jd_thd.`客户订单号` AS 退货,
	wdt.`分摊后总价` - zclsz.`采购价` * wdt.`实发数量` AS a 
FROM
	`旺店通` wdt
	LEFT JOIN `小柚旺店通销售管理` AS xywdt ON wdt.`子单原始单号` = xywdt.`原始单号`
	LEFT JOIN `自采销售单流水账` AS xyzcd ON xywdt.`小柚订单编码` = xyzcd.`单号` 
	AND wdt.`商家编码` = xyzcd.`物料号`
	LEFT JOIN `自采单流水账` AS zclsz ON wdt.`商家编码` = zclsz.`物料号` 
	AND zclsz.`批次号` = xyzcd.`批次号`
	LEFT JOIN ( SELECT * FROM `京东` WHERE 下单时间 BETWEEN @day_s AND @day_d ) AS jd ON wdt.`子单原始单号` = jd.`客户订单号` -- 退货单号
	LEFT JOIN (
		SELECT
			jd.`客户订单号` 
		FROM
			`京东` AS jd
			
			RIGHT JOIN 京东退货单 jd_t ON jd.`采购单号` = jd_t.`采购单号` 
		WHERE
			jd.下单时间 BETWEEN @day_s
			AND @day_d
		) AS jd_thd ON jd_thd.`客户订单号` = wdt.`子单原始单号`
WHERE
	wdt.`订单类型` = '网店销售' 
	AND xywdt.`订单类型` = '网店销售' 
	AND xywdt.`单据类型` = '销售订单' 
	AND wdt.`交易时间` BETWEEN @day_s 
	AND @day_d 
	AND xyzcd.`单据类型` = '自采销售单' 
	AND zclsz.`单据类型` = '自采单' 
	AND wdt.`店铺` = '世翔京喜自营店(京喜)' 
	AND ISNULL( jd_thd.`客户订单号` ) 
	
	
	-- 	) as a
-- SELECT *, DATE(下单时间),REPLACE(`客户订单号`,CHAR (9),"") 客户订单号  FROM `京东` WHERE DATE(下单时间) = '2021-11-01'