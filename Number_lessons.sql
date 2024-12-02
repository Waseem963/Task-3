-- FUNCTION version of first query


CREATE FUNCTION get_lessons_summary_by_year(year_input INT) 
RETURNS TABLE(
    "Month" TEXT,
    "Total" BIGINT,
    "Individual" BIGINT,
    "Group" BIGINT,
    "Ensemble" BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TO_CHAR(CASE 
                    WHEN p.lessonType = 'Individual' THEN COALESCE(l.appointmentTime, l.scheduledTime)
                    ELSE COALESCE(l.scheduledTime, l.appointmentTime)
                END, 'Mon') AS "Month", 
        COUNT(l.lessonId) AS "Total",
        SUM(CASE WHEN p.lessonType = 'Individual' THEN 1 ELSE 0 END) AS "Individual",
        SUM(CASE WHEN p.lessonType = 'Group' THEN 1 ELSE 0 END) AS "Group",
        SUM(CASE WHEN p.lessonType = 'Ensemble' THEN 1 ELSE 0 END) AS "Ensemble"
    FROM 
        lesson l
    JOIN 
        price_scheme p ON l.pricingId = p.pricingId
    WHERE 
        EXTRACT(YEAR FROM COALESCE(l.appointmentTime, l.scheduledTime)) = year_input
    GROUP BY 
        TO_CHAR(CASE 
                    WHEN p.lessonType = 'Individual' THEN COALESCE(l.appointmentTime, l.scheduledTime)
                    ELSE COALESCE(l.scheduledTime, l.appointmentTime)
                END, 'Mon'), 
        EXTRACT(MONTH FROM COALESCE(l.appointmentTime, l.scheduledTime))
    ORDER BY 
        EXTRACT(MONTH FROM COALESCE(l.appointmentTime, l.scheduledTime));
END; 
$$ LANGUAGE plpgsql;

-- View version of first query


CREATE VIEW view_lessons_summary_current_year AS
SELECT 
    TO_CHAR(CASE 
                WHEN p.lessonType = 'Individual' THEN COALESCE(l.appointmentTime, l.scheduledTime)
                ELSE COALESCE(l.scheduledTime, l.appointmentTime)
            END, 'Mon') AS "Month", 
    COUNT(l.lessonId) AS "Total",
    SUM(CASE WHEN p.lessonType = 'Individual' THEN 1 ELSE 0 END) AS "Individual",
    SUM(CASE WHEN p.lessonType = 'Group' THEN 1 ELSE 0 END) AS "Group",
    SUM(CASE WHEN p.lessonType = 'Ensemble' THEN 1 ELSE 0 END) AS "Ensemble"
FROM 
    lesson l
JOIN 
    price_scheme p ON l.pricingId = p.pricingId
WHERE 
    EXTRACT(YEAR FROM COALESCE(l.appointmentTime, l.scheduledTime)) = EXTRACT(YEAR FROM CURRENT_DATE) -- Current year
GROUP BY 
    TO_CHAR(CASE 
                WHEN p.lessonType = 'Individual' THEN COALESCE(l.appointmentTime, l.scheduledTime)
                ELSE COALESCE(l.scheduledTime, l.appointmentTime)
            END, 'Mon'), 
    EXTRACT(MONTH FROM COALESCE(l.appointmentTime, l.scheduledTime))
ORDER BY 
    EXTRACT(MONTH FROM COALESCE(l.appointmentTime, l.scheduledTime));