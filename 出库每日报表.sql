SELECT
	*,
(CASE

WHEN ((
`res`.`货品名称` LIKE '%移动电源%')
OR ( `res`.`货品名称` LIKE '%品胜%' )
OR ( `res`.`货品名称` LIKE '%无线蓝牙耳机%' )
OR ( `res`.`货品名称` LIKE '%手机壳%' )
OR ( `res`.`货品名称` LIKE '%充电器%' )
OR ( `res`.`货品名称` LIKE '%手环%' )) THEN
'其它'
WHEN ((
`res`.`货品名称` LIKE '%小米%'
)
OR ( `res`.`货品名称` LIKE '%Redmi%' )
OR ( `res`.`货品名称` LIKE '%红米%' )) THEN
'小米'
WHEN ((
`res`.`货品名称` LIKE '%APPLE%'
)
OR ( `res`.`货品名称` LIKE '%苹果%' )) THEN
'苹果'
WHEN ((
`res`.`货品名称` LIKE '%荣耀%'
)
OR ( `res`.`货品名称` LIKE '%华为荣耀%' )) THEN
'荣耀'
WHEN ((
`res`.`货品名称` LIKE '%华为%'
)
OR ( `res`.`货品名称` LIKE '%HUAWEI%' )) THEN
'华为'
WHEN ( `res`.`货品名称` LIKE '%OPPO%' ) THEN
'OPPO'
WHEN ((
`res`.`货品名称` LIKE '%realme%'
)
OR ( `res`.`货品名称` LIKE '%真我%' )) THEN
'realme真我'
WHEN ((
`res`.`货品名称` LIKE '%酷派%'
)
OR ( `res`.`货品名称` LIKE '%COOL%' )) THEN
'酷派'
WHEN ( `res`.`货品名称` LIKE '%黑鲨%' ) THEN
'黑鲨'
WHEN ( `res`.`货品名称` LIKE '%努比亚%' ) THEN
'努比亚'
WHEN ( `res`.`货品名称` LIKE '%vivo%' ) or  `res`.`货品名称` like '%iQOO%'THEN
'vivo'
WHEN ( `res`.`货品名称` LIKE '%60 前后双曲设计 1亿像素清摄影 高通骁龙778G 5G 66W智慧级通版 8G 幻境星空 12GB+256GB%' ) THEN
'未知品牌' ELSE '其它'
END
) AS `品牌`


					FROM
						(
						SELECT
							ck.店铺,
							ck.`子单原始单号`,
							ck.货品名称,
							ck.货品数量,
							ck.货品成交总价,
							xs.`交易时间` 
						FROM
							`旺店通_出库单明细` AS ck
							LEFT JOIN `旺店通_销售明细` AS xs ON xs.`子单原始单号` = ck.`子单原始单号` UNION
						SELECT
							店铺,
							`子单原始单号`,
							货品名称,
							`下单数量` AS 货品数量,分摊后总价 AS 货品成交总价,交易时间 
						FROM
							`旺店通_销售明细` 
						WHERE
							`子单原始单号` NOT IN ( SELECT xs.`子单原始单号` FROM `旺店通_销售明细` xs RIGHT JOIN `旺店通_出库单明细` AS ck ON xs.`子单原始单号` = ck.`子单原始单号` WHERE 订单状态 != '已取消' ) 
							AND 订单状态 != '已取消' 
						) AS res 
						
						
						UNION ALL
						
						
					SELECT
						'京东星宇电竞' AS 店铺,
						'' AS 子单原始单号,
						dj.商品名称 AS 货品名称,
						dj.成交单量 AS 货品数量,
						dj.成交金额 AS 货品成交总价,
						dj.日期 AS 交易时间,
						(CASE

WHEN ((
`dj`.`商品名称` LIKE '%移动电源%'
)
OR ( `dj`.`商品名称` LIKE '%品胜%' )
OR ( `dj`.`商品名称` LIKE '%无线蓝牙耳机%' )
OR ( `dj`.`商品名称` LIKE '%手机壳%' )
OR ( `dj`.`商品名称` LIKE '%充电器%' )
OR ( `dj`.`商品名称` LIKE '%手环%' )) THEN
'其它'
WHEN ((
`dj`.`商品名称` LIKE '%小米%'
)
OR ( `dj`.`商品名称` LIKE '%Redmi%' )
OR ( `dj`.`商品名称` LIKE '%红米%' )) THEN
'小米'
WHEN ((
`dj`.`商品名称` LIKE '%APPLE%'
)
OR ( `dj`.`商品名称` LIKE '%苹果%' )) THEN
'苹果'
WHEN ((
`dj`.`商品名称` LIKE '荣耀%'
)
OR ( `dj`.`商品名称` LIKE '%华为荣耀%' )) THEN
'荣耀'
WHEN ((
`dj`.`商品名称` LIKE '%华为%'
)
OR ( `dj`.`商品名称` LIKE '%HUAWEI%' )) THEN
'华为'
WHEN ( `dj`.`商品名称` LIKE '%OPPO%' ) THEN
'OPPO'
WHEN ((
`dj`.`商品名称` LIKE '%realme%'
)
OR ( `dj`.`商品名称` LIKE '%真我%' )) THEN
'realme真我'
WHEN ((
`dj`.`商品名称` LIKE '%酷派'
)
OR ( `dj`.`商品名称` LIKE '%COOL%' )) THEN
'酷派'
WHEN ( `dj`.`商品名称` LIKE '%黑鲨%' ) THEN
'黑鲨'
WHEN ( `dj`.`商品名称` LIKE '%努比亚%' ) THEN
'努比亚'
WHEN ( `dj`.`商品名称` LIKE '%vivo%' ) or  `dj`.`商品名称` like '%iQOO%'THEN
'vivo'
WHEN ( `dj`.`商品名称` LIKE '%60 前后双曲设计 1亿像素清摄影 高通骁龙778G 5G 66W智慧级通版 8G 幻境星空 12GB+256GB%' ) THEN
'未知品牌' 
WHEN ( `dj`.`商品名称` LIKE '%摩托罗拉%' OR  `dj`.`商品名称` LIKE '%moto%') THEN
'MOTO'
WHEN ( `dj`.`商品名称` LIKE '%魅族%' OR  `dj`.`商品名称` LIKE '%魅族%') THEN
'魅族'
ELSE '其它'
END
) AS `品牌`

										FROM
											`电竞业务数据` AS dj 
										WHERE
										dj.日期 > '2021-12-31' 
	AND dj.成交单量 <> '0'