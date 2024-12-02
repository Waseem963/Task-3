CREATE TYPE types AS ENUM ('Individual', 'Group', 'Ensemble');
CREATE TYPE levels AS ENUM ('Beginner', 'Intermediate', 'Advanced');

CREATE TABLE contact_person (
 contactId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 phoneNumber VARCHAR(200),
 emailAddress VARCHAR(200)
);

ALTER TABLE contact_person ADD CONSTRAINT PK_contact_person PRIMARY KEY (contactId);


CREATE TABLE instrument (
 instrumentId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 name VARCHAR(200) NOT NULL,
 type VARCHAR(200) NOT NULL,
 brand VARCHAR(200),
 monthlyFee DECIMAL(10, 2) NOT NULL,
 UNIQUE(type)
);

ALTER TABLE instrument ADD CONSTRAINT PK_instrument PRIMARY KEY (instrumentId);

CREATE TYPE statusForInsturment AS ENUM ('Available', 'Rented');
CREATE TABLE instrument_stack (
 stackId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 instrumentId INT NOT NULL,
 status statusForInsturment
);

ALTER TABLE instrument_stack ADD CONSTRAINT PK_instrument_stack PRIMARY KEY (stackId);


CREATE TABLE person_address (
 addressId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 city VARCHAR(200) NOT NULL,
 street VARCHAR(200) NOT NULL,
 zipCode VARCHAR(200) NOT NULL
);

ALTER TABLE person_address ADD CONSTRAINT PK_person_address PRIMARY KEY (addressId);


CREATE TABLE price_scheme (
 pricingId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 amount DECIMAL(10) NOT NULL,
 validFrom TIMESTAMP NOT NULL,
 lessonLevel levels NOT NULL,
 lessonType types NOT NULL,
 siblingDiscount DECIMAL(10)
);

ALTER TABLE price_scheme ADD CONSTRAINT PK_price_scheme PRIMARY KEY (pricingId);


CREATE TABLE person (
 personId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 name VARCHAR(200) NOT NULL,
 phoneNumber VARCHAR(200) NOT NULL,
 emailAddress VARCHAR(200) NOT NULL,
 addressId INT NOT NULL,
 personalNo CHAR(12) NOT NULL,
 UNIQUE(personalNo)
);

ALTER TABLE person ADD CONSTRAINT PK_person PRIMARY KEY (personId);


CREATE TABLE student (
 studentId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 contactId INT,
 personId INT NOT NULL
);

ALTER TABLE student ADD CONSTRAINT PK_student PRIMARY KEY (studentId);


CREATE TABLE instructor (
 instructorId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 canTeachEnsemble SMALLINT,
 personId INT NOT NULL
);

ALTER TABLE instructor ADD CONSTRAINT PK_instructor PRIMARY KEY (instructorId);


CREATE TABLE instructor_availability (
 availabilityId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 availableFrom TIMESTAMP NOT NULL,
 availableTo TIMESTAMP NOT NULL,
 instructorId INT NOT NULL
);

ALTER TABLE instructor_availability ADD CONSTRAINT PK_instructor_availability PRIMARY KEY (availabilityId);


CREATE TABLE instrument_rental (
 rentalId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 rentalStartDate DATE NOT NULL,
 rentalEndDate DATE,
 studentId INT NOT NULL,
 stackId INT NOT NULL
);

ALTER TABLE instrument_rental ADD CONSTRAINT PK_instrument_rental PRIMARY KEY (rentalId);
/*Trigger to make sure that a student can rent instrument up to 12 months, aslo maximum rent for a student is 2 instruments*/
CREATE OR REPLACE FUNCTION enforce_rental_constraints()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the student already has 2 active rentals
    IF (SELECT COUNT(*) 
        FROM instrument_rental 
        WHERE studentId = NEW.studentId AND rentalEndDate IS NULL) >= 2 THEN
        RAISE EXCEPTION 'A student cannot rent more than 2 instruments concurrently.';
    END IF;

    -- Check if the rental duration exceeds 12 months
    IF (NEW.rentalEndDate - NEW.rentalStartDate) > INTERVAL '12 months' THEN
        RAISE EXCEPTION 'Rental duration cannot exceed 12 months.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*Create the trigger*/
CREATE TRIGGER rental_constraints_trigger
BEFORE INSERT OR UPDATE ON instrument_rental
FOR EACH ROW EXECUTE FUNCTION enforce_rental_constraints();

CREATE TABLE lesson (
 lessonId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 instrumentId INT,
 scheduledTime TIMESTAMP,
 appointmentTime TIMESTAMP,
 minCapacity INT NOT NULL,
 maxCapacity INT NOT NULL,
 instructorId INT NOT NULL,
 pricingId INT NOT NULL
);

ALTER TABLE lesson ADD CONSTRAINT PK_lesson PRIMARY KEY (lessonId);


CREATE TABLE siblings (
 studentId INT NOT NULL,
 siblingId INT NOT NULL
);

ALTER TABLE siblings ADD CONSTRAINT PK_siblings PRIMARY KEY (studentId,siblingId);


CREATE TABLE available_Instruments (
 availabilityId INT NOT NULL,
 instrumentId INT NOT NULL
);

ALTER TABLE available_Instruments ADD CONSTRAINT PK_available_Instruments PRIMARY KEY (availabilityId,instrumentId);

CREATE TYPE statusForBooking AS ENUM ('Confirmed', 'Cancelled');

CREATE TABLE booking	 (
 bookingId INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 status statusForBooking,
 studentId INT,
 lessonId INT
);

ALTER TABLE booking	 ADD CONSTRAINT PK_booking	 PRIMARY KEY (bookingId);


CREATE TABLE ensemble (
 lessonId INT NOT NULL,
 name VARCHAR(200) NOT NULL,
 targetGenre VARCHAR(200) NOT NULL
);

ALTER TABLE ensemble ADD CONSTRAINT PK_ensemble PRIMARY KEY (lessonId);


ALTER TABLE instrument_stack ADD CONSTRAINT FK_instrument_stack_0 FOREIGN KEY (instrumentId) REFERENCES instrument (instrumentId);


ALTER TABLE person ADD CONSTRAINT FK_person_0 FOREIGN KEY (addressId) REFERENCES person_address (addressId) ON DELETE SET NULL;


ALTER TABLE student ADD CONSTRAINT FK_student_0 FOREIGN KEY (contactId) REFERENCES contact_person (contactId) ON DELETE SET NULL;
ALTER TABLE student ADD CONSTRAINT FK_student_1 FOREIGN KEY (personId) REFERENCES person (personId);


ALTER TABLE instructor ADD CONSTRAINT FK_instructor_0 FOREIGN KEY (personId) REFERENCES person (personId);


ALTER TABLE instructor_availability ADD CONSTRAINT FK_instructor_availability_0 FOREIGN KEY (instructorId) REFERENCES instructor (instructorId);


ALTER TABLE instrument_rental ADD CONSTRAINT FK_instrument_rental_0 FOREIGN KEY (studentId) REFERENCES student (studentId);
ALTER TABLE instrument_rental ADD CONSTRAINT FK_instrument_rental_1 FOREIGN KEY (stackId) REFERENCES instrument_stack (stackId);


ALTER TABLE lesson ADD CONSTRAINT FK_lesson_0 FOREIGN KEY (instrumentId) REFERENCES instrument (instrumentId);
ALTER TABLE lesson ADD CONSTRAINT FK_lesson_1 FOREIGN KEY (instructorId) REFERENCES instructor (instructorId);
ALTER TABLE lesson ADD CONSTRAINT FK_lesson_2 FOREIGN KEY (pricingId) REFERENCES price_scheme (pricingId);


ALTER TABLE siblings ADD CONSTRAINT FK_siblings_0 FOREIGN KEY (studentId) REFERENCES student (studentId) ON DELETE CASCADE;
ALTER TABLE siblings ADD CONSTRAINT FK_siblings_1 FOREIGN KEY (siblingId) REFERENCES student (studentId) ON DELETE CASCADE;


ALTER TABLE available_Instruments ADD CONSTRAINT FK_available_Instruments_0 FOREIGN KEY (availabilityId) REFERENCES instructor_availability (availabilityId) ON DELETE CASCADE;
ALTER TABLE available_Instruments ADD CONSTRAINT FK_available_Instruments_1 FOREIGN KEY (instrumentId) REFERENCES instrument (instrumentId) ON DELETE CASCADE;


ALTER TABLE booking	 ADD CONSTRAINT FK_booking_0 FOREIGN KEY (studentId) REFERENCES student (studentId);
ALTER TABLE booking	 ADD CONSTRAINT FK_booking_1 FOREIGN KEY (lessonId) REFERENCES lesson (lessonId) ON DELETE CASCADE;


ALTER TABLE ensemble ADD CONSTRAINT FK_ensemble_0 FOREIGN KEY (lessonId) REFERENCES lesson (lessonId) ON DELETE CASCADE;


