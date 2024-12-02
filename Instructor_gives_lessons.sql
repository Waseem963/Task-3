
 --View version of third query

CREATE VIEW view_instructor_by_month_count AS
SELECT 
    i.instructorId AS "Instructor Id",
    p.name AS "Name",
    COUNT(l.lessonId) AS "No of Lessons"
FROM 
    lesson l
JOIN 
    instructor i ON l.instructorId = i.instructorId
JOIN 
    person p ON i.personId = p.personId
JOIN 
    price_scheme ps ON l.pricingId = ps.pricingId
WHERE 
    EXTRACT(YEAR FROM COALESCE(l.appointmentTime, l.scheduledTime)) = EXTRACT(YEAR FROM CURRENT_DATE)
    AND EXTRACT(MONTH FROM COALESCE(l.appointmentTime, l.scheduledTime)) = EXTRACT(MONTH FROM CURRENT_DATE)
GROUP BY 
    i.instructorId, p.name
HAVING 
    COUNT(l.lessonId) > 0
ORDER BY 
    "No of Lessons" DESC;


 --FUNCTION version of third query


CREATE FUNCTION func_instructors_with_lessons(lesson_count INT)
RETURNS TABLE("Instructor Id" INT, "Name" VARCHAR, "No of Lessons" BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.instructorId AS "Instructor Id",
        p.name AS "Name",
        COUNT(l.lessonId) AS "No of Lessons"
    FROM 
        lesson l
    JOIN 
        instructor i ON l.instructorId = i.instructorId
    JOIN 
        person p ON i.personId = p.personId
    JOIN 
        price_scheme ps ON l.pricingId = ps.pricingId
    WHERE 
        EXTRACT(YEAR FROM COALESCE(l.appointmentTime, l.scheduledTime)) = EXTRACT(YEAR FROM CURRENT_DATE)
        AND EXTRACT(MONTH FROM COALESCE(l.appointmentTime, l.scheduledTime)) = EXTRACT(MONTH FROM CURRENT_DATE)
    GROUP BY 
        i.instructorId, p.name
    HAVING 
        COUNT(l.lessonId) > lesson_count
    ORDER BY 
        "No of Lessons" DESC;
END;
$$ LANGUAGE plpgsql;
