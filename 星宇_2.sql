
SELECT 
		*,
		(CASE WHEN 
					NOT ISNULL(a.采购单价) AND a.金额 < 0  
					THEN -a.采购单价*a.`商品数量` 
			WHEN a.采购单价 >= 1
					THEN a.采购单价*a.`商品数量`
			WHEN  ISNULL(a.采购单价) AND a.金额 >= 0
					THEN a.`支出金额(元)`
			ELSE -a.`支出金额(元)` 
			END 
			) as 采购金额,
		(CASE WHEN a.采购单价 THEN '自采' ELSE '一盘货' END ) as 订单类型,
		 a.金额 - (CASE WHEN 
					NOT ISNULL(a.采购单价) AND a.金额 < 0  
					THEN -a.采购单价*a.`商品数量` 
			WHEN a.采购单价 >= 1
					THEN a.采购单价*a.`商品数量`
			WHEN  ISNULL(a.采购单价) AND a.金额 >= 0
					THEN a.`支出金额(元)`
			ELSE -a.`支出金额(元)` 
			END 
			) AS 毛利
		FROM
		(
			SELECT
			`星宇_钱包订单明细`.`订单编号`,`星宇_钱包订单明细`.`商品名称`,`星宇_钱包订单明细`.单据类型,`星宇_钱包订单明细`.商户订单号,`星宇_钱包订单明细`.费用项,`星宇_钱包订单明细`.`对账日期`,
			SUM(`星宇_钱包订单明细`.金额) as 金额,直赔.直赔,
			
			自采价格.采购单价,
			一盘货.`支出金额(元)`,
			
			(CASE WHEN SUM(`星宇_钱包订单明细`.金额) > 0 AND SUM(`星宇_钱包订单明细`.金额) < ABS(MIN(`星宇_钱包订单明细`.金额)) THEN 0 ELSE SUM(`星宇_钱包订单明细`.`商品数量`)  END ) as 商品数量
			
			FROM `星宇_钱包订单明细`
			LEFT JOIN (
				SELECT * FROM (			
					SELECT wdt_ct.序列号,wdt_ct.原始单号,xy_xlh.采购单价
					FROM `旺店通_出库序列号明细` as wdt_ct
					LEFT JOIN `星宇_序列号明细` as xy_xlh
					ON wdt_ct.`序列号` = xy_xlh.`序列号`
								) t
				GROUP BY t.`原始单号`
			) as 自采价格
			ON 自采价格.原始单号 = `星宇_钱包订单明细`.订单编号
			
			LEFT JOIN (
				SELECT 
					RIGHT(`星宇_钱包一盘货`.交易备注,12) as `订单编号`
					,`支出金额(元)`
				FROM `星宇_钱包一盘货`
				WHERE (`账单日期` = '' OR ISNULL(`账单日期`))
				AND `支出金额(元)` != '' AND `支出金额(元)` != '--'
				AND  `星宇_钱包一盘货`.交易备注 NOT LIKE '%直赔退款代扣%'
			) AS  一盘货
			ON 一盘货.`订单编号` = `星宇_钱包订单明细`.订单编号 
			
			LEFT JOIN (
				SELECT 
-- 				`星宇_钱包一盘货`.交易备注,
					 RIGHT(`星宇_钱包一盘货`.交易备注,12) as `订单编号`
-- 					 ,`支出金额(元)`
					,SUM(`支出金额(元)`) as 直赔
				FROM `星宇_钱包一盘货`
				WHERE `账单日期` = ''
				AND `支出金额(元)` != '' AND `支出金额(元)` != '--'
				AND  `星宇_钱包一盘货`.交易备注 LIKE '%直赔退款代扣%'
				GROUP BY  RIGHT(`星宇_钱包一盘货`.交易备注,12)
			) AS 直赔

			ON 直赔.`订单编号` = `星宇_钱包订单明细`.`订单编号`

			
			WHERE (费用项 = "货款" OR 费用项 = "售后卖家赔付费" OR  费用项 = '价保扣款')
-- 			AND 对账日期 IN('20220117','20220118','20220119','20220120','20220121','20220122')
-- 			AND 对账日期 LIKE '202112%'
-- 			AND `对账日期` BETWEEN '20211130' AND '20211230'
-- 			AND `对账日期` BETWEEN '20211111' AND '20211129'
-- 			AND `对账日期` BETWEEN '20211231' AND '20220126'
			GROUP BY `订单编号`	
			HAVING 金额 <> 0
)a
