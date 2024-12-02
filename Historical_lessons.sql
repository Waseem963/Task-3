
CREATE TABLE historical_lessons (
    historicalLessonId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lessonId INT NOT NULL,  -- Lesson ID
    studentId INT NOT NULL, -- Student ID for uniqueness and tracking
    lessonType types NOT NULL, -- Individual, Group, Ensemble
    genre VARCHAR(200), -- Genre for ensemble lessons (NULL for others)
    instrument VARCHAR(200), -- Instrument for individual/group lessons (NULL for ensemble)
    lessonPrice DECIMAL(10, 2) NOT NULL, -- Price of the lesson at the time it was conducted
    studentName VARCHAR(200) NOT NULL, -- Student name
    studentEmail VARCHAR(200) NOT NULL, -- Student email
    UNIQUE (lessonId, studentId) -- Prevent duplicates for same student and lesson
);


INSERT INTO historical_lessons (lessonId, studentId, lessonType, instrument, lessonPrice, studentName, studentEmail)
SELECT 
    l.lessonId,
    b.studentId,
    ps.lessonType,
    i.name AS instrument,
    ps.amount AS lessonPrice,
    p.name AS studentName,
    p.emailAddress AS studentEmail
FROM 
    lesson l
JOIN 
    price_scheme ps ON l.pricingId = ps.pricingId
JOIN 
    instrument i ON l.instrumentId = i.instrumentId
JOIN 
    booking b ON l.lessonId = b.lessonId
JOIN 
    student s ON b.studentId = s.studentId
JOIN 
    person p ON s.personId = p.personId
WHERE 
    ps.lessonType IN ('Individual', 'Group') -- Only Individual and Group lessons
    AND b.status = 'Confirmed'; -- Only Confirmed bookings


INSERT INTO historical_lessons (lessonId, studentId, lessonType, genre, lessonPrice, studentName, studentEmail)
SELECT 
    l.lessonId,
    b.studentId,
    ps.lessonType,
    e.targetGenre AS genre,
    ps.amount AS lessonPrice,
    p.name AS studentName,
    p.emailAddress AS studentEmail
FROM 
    lesson l
JOIN 
    price_scheme ps ON l.pricingId = ps.pricingId
JOIN 
    ensemble e ON l.lessonId = e.lessonId
JOIN 
    booking b ON l.lessonId = b.lessonId
JOIN 
    student s ON b.studentId = s.studentId
JOIN 
    person p ON s.personId = p.personId
WHERE 
    ps.lessonType = 'Ensemble' -- Only Ensemble lessons
    AND b.status = 'Confirmed'; -- Only Confirmed bookings
