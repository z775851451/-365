SELECT * FROM `电竞业务数据`
GROUP BY `日期`,`商品名称`



SELECT
	jr.`日期`,
	jr.`商品ID`,
	jr.`商品名称`,
	jr.`成交单量`, 
	jr.`访客数`,
	zr.*,
	ROUND((jr.成交单量-zr.成交单量)/zr.成交单量*100,2) as 单量环比,
	ROUND((jr.`访客数`-zr.`访客数`)/zr.`访客数`*100,2) as 访客环比
FROM
	`电竞业务数据` AS jr
	LEFT JOIN ( SELECT 日期,成交单量,`访客数`,商品名称,商品ID,日期-1 as rq FROM `电竞业务数据` ) AS zr
	ON jr.`日期` = zr.rq 
	AND jr.`商品ID` = zr.`商品ID`

where jr.`商品ID` = "10042888468942"
ORDER BY rq DESC

