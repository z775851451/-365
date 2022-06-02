-- `vc结算单`
SELECT MIN(结算日期),MAX(结算日期)
FROM `vc结算单`

-- `京东`
SELECT MIN(下单时间),MAX(下单时间)
FROM `京东`


-- `京东退货单`
SELECT MIN(`制单日期`),MAX(`制单日期`)
FROM `京东退货单`


-- `苏宁报表`
SELECT MIN(`订单下单时间`),MAX(`订单下单时间`)
FROM `苏宁报表`


-- `旺店通`
SELECT MIN(`交易时间`),MAX(`交易时间`)
FROM `旺店通`


-- `小柚旺店通销售管理`
SELECT MIN(日期),MAX(日期)
FROM `小柚旺店通销售管理`


-- `快递费`
SELECT MIN(付款时间),MAX(付款时间)
FROM `快递费`





-- 