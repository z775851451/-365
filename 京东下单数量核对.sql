#数量测试  (平台&退货单\旺店通京东)
SELECT * FROM(
SELECT *,ac-bc as c FROM
(SELECT 
	jd.`客户订单号`,
	SUM(jd.`购买数量`) as ac
	FROM (SELECT DISTINCT(退货单号),`采购单号` FROM `京东退货单`) jd_th
	LEFT JOIN `京东` jd
	ON jd_th.`采购单号` = jd.`采购单号`
	WHERE jd.`客户订单号` != ''
	GROUP BY jd.`客户订单号`)as a
	LEFT JOIN(
			SELECT
			wdt.`子单原始单号`,
			SUM(wdt.`下单数量`) as bc
			FROM `旺店通` wdt
			WHERE wdt.`子单原始单号` IN
			#退货单号
				(SELECT 
				jd.`客户订单号`
				FROM `京东退货单` jd_th
				LEFT JOIN `京东` jd
				ON jd_th.`采购单号` = jd.`采购单号`
				WHERE jd.`客户订单号` != '')
			AND wdt.`店铺` = "世翔京喜自营店(京喜)"
-- 			AND wdt.`子单原始单号` = "199224242476"
			GROUP BY wdt.`子单原始单号`
				)as b
ON b.`子单原始单号` = a.`客户订单号`)cha
WHERE cha.c != 0
	
#去除退货保留的单号
SELECT *,ac-bc as c 
FROM
(SELECT 
	jd.`客户订单号`,
	SUM(jd.`购买数量`) as ac
	FROM (SELECT DISTINCT(退货单号),`采购单号` FROM `京东退货单`) jd_th
	LEFT JOIN `京东` jd
	ON jd_th.`采购单号` = jd.`采购单号`
	WHERE jd.`客户订单号` != ''
	GROUP BY jd.`客户订单号`)as a
	LEFT JOIN(
			SELECT
			wdt.`子单原始单号`
			FROM `旺店通` wdt
			WHERE wdt.`子单原始单号` IN
			#退货单号
				(SELECT 
				jd.`客户订单号`
				FROM (SELECT DISTINCT(退货单号),`采购单号` FROM `京东退货单`) jd_th
				LEFT JOIN `京东` jd
				ON jd_th.`采购单号` = jd.`采购单号`
				WHERE jd.`客户订单号` != ''
				)
			AND wdt.`店铺` = "世翔京喜自营店(京喜)"
-- 			AND wdt.`子单原始单号` = "199224242476"
				)as b
ON b.`子单原始单号` = a.`客户订单号`



#最终除退货单,全部单号,去重之后
SELECT
	DISTINCT(wdt.`子单原始单号`)
	FROM `旺店通` wdt
	WHERE wdt.`子单原始单号` NOT IN
	#退货单号
		(SELECT 
		jd.`客户订单号`
		FROM (SELECT DISTINCT(退货单号),`采购单号` FROM `京东退货单`) jd_th
		LEFT JOIN `京东` jd
		ON jd_th.`采购单号` = jd.`采购单号`
		WHERE jd.`客户订单号` != '')
AND wdt.`店铺` = "世翔京喜自营店(京喜)"
AND wdt.`子单原始单号` NOT IN
		(SELECT 客户订单号 FROM `京东`
		WHERE `退货单号` != '')
		AND wdt.`订单状态` IN("已发货","已完成")
		AND `子单原始单号` NOT LIKE "%TCM%"
-- 	AND `交易时间` BETWEEN '2021-10-01'AND'2021-11-01'



-- 需要优化
SELECT DISTINCT
	`wdt`.`子单原始单号` AS `子单原始单号` 
FROM
	`旺店通` `wdt` 
WHERE
	(
		`wdt`.`子单原始单号` IN (
		SELECT
			`jd`.`客户订单号` 
		FROM
			((
				SELECT DISTINCT
					`京东退货单`.`退货单号` AS `退货单号`,
					`京东退货单`.`采购单号` AS `采购单号` 
				FROM
					`京东退货单` 
					) `jd_th`
				LEFT JOIN `京东` `jd` ON ((
						`jd_th`.`采购单号` = `jd`.`采购单号` 
					))) 
		WHERE
		( `jd`.`客户订单号` <> '' )) IS FALSE 
		AND ( `wdt`.`店铺` = '世翔京喜自营店(京喜)' ) 
		AND `wdt`.`子单原始单号` IN (
		SELECT
			`京东`.`客户订单号` 
		FROM
			`京东` 
		WHERE
		( `京东`.`退货单号` <> ''  OR `订单状态` = "删除")) IS FALSE 
	)

AND wdt.`交易时间` BETWEEN '2021-10-01'AND'2021-11-01'
AND `订单类型` = "网店销售"
AND `子单原始单号` NOT LIKE "%TCM%"
AND `订单状态` IN("已发货","已完成")












SELECT
	DISTINCT(wdt.`子单原始单号`)
	FROM `旺店通` wdt
	WHERE wdt.`子单原始单号` NOT IN
	#退货单号
		(SELECT 
		jd.`客户订单号`
		FROM (SELECT DISTINCT(退货单号),`采购单号` FROM `京东退货单`) jd_th
		LEFT JOIN `京东` jd
		ON jd_th.`采购单号` = jd.`采购单号`
		WHERE jd.`客户订单号` != '')
AND wdt.`店铺` = "世翔京喜自营店(京喜)"
AND wdt.`子单原始单号` NOT IN
		(SELECT 客户订单号 FROM `京东`
		WHERE `退货单号` != '')
		
AND wdt.`交易时间` BETWEEN '2021-10-01'AND'2021-11-01'


