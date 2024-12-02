-- View version of fourth query
4.

CREATE VIEW view_next_week_ensemble AS
select
    TO_CHAR(l.scheduledtime, 'Day') AS "Day", 
    e.targetgenre AS "Genre",
    (CASE
    WHEN l.maxcapacity - COALESCE(b.count,0) = 0 THEN 'No Seats'
    WHEN l.maxcapacity - COALESCE(b.count,0) BETWEEN 1 AND 2 THEN '1 or 2 Seats'
    WHEN l.maxcapacity - COALESCE(b.count,0) > 2 THEN 'Many Seats' 
    END) AS "No of Free Seats"
from ensemble e
left join lesson l on l.lessonid = e.lessonid
left join (select b.lessonid, COUNT(*) from booking b group by b.lessonid) b on b.lessonid = e.lessonid
left join price_scheme ps on ps.pricingid = l.pricingid
   WHERE EXTRACT('week' FROM l.scheduledTime) = EXTRACT('week' FROM CURRENT_DATE) + 1
  AND EXTRACT('year' FROM l.scheduledTime) = EXTRACT('year' FROM CURRENT_DATE)

