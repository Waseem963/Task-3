 --View version of second query

CREATE VIEW view_students_by_sibling_count AS
SELECT 
    sibling_count AS "No of Siblings",
    COUNT(*) AS "No of Students"
FROM (
    SELECT 
        s.studentId,
        COUNT(DISTINCT sib.siblingId) AS sibling_count
    FROM 
        student s
    LEFT JOIN 
        siblings sib ON s.studentId = sib.studentId
    GROUP BY  
        s.studentId
) student_sibling_counts
WHERE sibling_count IN (0, 1, 2) -- Only include 0, 1, or 2 siblings as per the requirements
GROUP BY 
    sibling_count
ORDER BY 
    sibling_count;
