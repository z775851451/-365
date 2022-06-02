select res.id
,
-- 	(
-- 		case 	
-- 		when ISNULL(res.id1)
-- 			then "Root"
-- 			
-- 		when res.id2 > 1
-- 			then "Inner"
-- 					
-- 		when res.id2 <= 1
-- 			then "Leaf"
-- 			
-- 			else 0
-- 				
--     END
-- ) as r,
-- id1,

-- 0000000000
(
	CASE  
	WHEN cs.p_id = 1 OR ISNULL(id1) THEN
		"Root"
	WHEN cs.p_id = 2 THEN
		"Inner"
	WHEN ISNULL(cs.p_id) THEN
		"Leaf"
	ELSE 0
	
END

)as Type

FROM
(
	select t1.id as id,t1.p_id as id1
	,count(*) as id2
		FROM tree as t1
		left JOIN tree as t2
	on t2.p_id = t1.id
	GROUP BY t1.id
)as res
LEFT JOIN (
	select 
		t1.p_id,count(*)
		FROM tree as t1
		left JOIN tree as t2
		on t2.p_id = t1.id
	GROUP BY t1.p_id  	 
)as cs
on cs.p_id = res.id












-- 	select t1.id as id,t1.p_id as id1
-- 	,count(*) as id2
-- 		FROM tree as t1
-- 		left JOIN tree as t2
-- 	on t2.p_id = t1.id
-- 	GROUP BY t1.id
-- 
-- 




-- 
-- select id,(
--     CASE 
--         when isnull(p_id)
--             then "Root"
--         when p_id  = "1"
--             then "Inner"
--         when p_id  = "2"
--             then "Leaf"
--         else 0
--     END
-- ) as d
-- from tree