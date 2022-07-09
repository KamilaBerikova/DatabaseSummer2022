-- Exercise # 1
-- A. Find all courses worth more than 3 credits;
SELECT *
FROM course
WHERE credits > 3;

--B. Find all classrooms situated either in ‘Watson’ or ‘Packard’ buildings
SELECT *
FROM classroom
WHERE building IN ('Packard','Watson');
-- OR
SELECT *
FROM classroom
WHERE building LIKE 'Watson' OR 'Packard';

--C. Find all courses offered by the Computer Science department;

SELECT *
FROM course
WHERE dept_name LIKE 'Comp%Sci%';

--D. Find all courses offered during fall;
SELECT *
FROM section
WHERE semester = 'Fall';

--E. Find all students who have more than 45 credits but less than 90;
SELECT *
FROM student
WHERE tot_cred BETWEEN 46 AND 89;
-- OR
SELECT *
FROM student
WHERE tot_cred > 46 AND tot_cred < 89;

--F. Find all students whose names end with vowels
SELECT *
FROM student
WHERE name LIKE '%a' OR
      name LIKE '%e' OR
      name LIKE '%i' OR
      name LIKE '%o' OR
      name LIKE '%u';

--G. Find all courses which have course ‘CS-101’ as their prerequisite;
SELECT *
FROM prereq
WHERE prereq_id LIKE 'CS-101';

-- Exercise 2

-- A
-- For each department, find the average salary of instructors in that
-- department and list them in ascending order. Assume that every
-- department has at least one instructor;
SELECT dept_name, AVG(salary) AS average_dept_salary
FROM instructor
GROUP BY dept_name
ORDER BY average_dept_salary;

--B  Find the building where the biggest number of courses takes place;

SELECT  building, COUNT(course_id) AS courses_number
FROM section
GROUP BY building
ORDER BY courses_number DESC
LIMIT 1;

-- C. Find the department with the lowest number of courses offered;
SELECT dept_name, COUNT(course_id) AS number_courses
FROM course
GROUP BY dept_name
HAVING COUNT(course_id) =
       (SELECT COUNT(course_id) AS number_courses
        FROM course
        GROUP BY dept_name
        ORDER BY number_courses ASC
        LIMIT 1);

-- D. Find the ID and name of each student who has taken more than 3 courses from the Computer Science department;
SELECT student.id, student.name
FROM student
WHERE student.id IN (SELECT takes.id FROM takes
WHERE course_id IN
      (SELECT course_id FROM course
        WHERE dept_name LIKE 'Comp%Sci%')
GROUP BY takes.id
HAVING COUNT(course_id) > 3);

-- E. Find all instructors who work either in Biology, Philosophy, or Music departments;
SELECT *
FROM instructor
WHERE dept_name IN ('Biology','Philosophy','Music');

-- F  Find all instructors who taught in the 2018 year but not in the 2017 year
SELECT *
FROM instructor
    WHERE id IN (SELECT DISTINCT(teaches.id) FROM teaches
WHERE id NOT IN (SELECT DISTINCT (id) FROM teaches
WHERE year = 2017) AND year = 2018);

-- EXERCISE 3

--A. Find all students who have taken Comp. Sci. course and got an excellent grade (i.e., A, or A-) and sort them alphabetically;
SELECT *
FROM student
WHERE id IN ( SELECT id FROM takes
WHERE course_id IN (SELECT course_id
                    FROM course
                    WHERE dept_name LIKE 'Comp%Sci%') AND
      grade IN ('A','A-'));

-- B. Find all advisors of students who got grades lower than B on any class

SELECT *
FROM instructor
    WHERE id IN (SELECT i_id FROM advisor
WHERE s_id IN (SELECT id FROM takes WHERE grade NOT IN ('B','B+','A-','A')));

--C.  Find all departments whose students have never gotten an F or C grade
SELECT *
FROM department WHERE dept_name NOT IN  (SELECT dept_name FROM student
    WHERE id IN (SELECT id FROM takes WHERE grade = 'F' OR grade = 'C'));

--D. Find all instructors who have never given an A grade in any of the courses they taught;

SELECT *
FROM instructor
    WHERE id NOT IN (SELECT id FROM teaches
    WHERE (course_id,sec_id,semester,year) IN (SELECT course_id,sec_id,semester,year FROM takes WHERE grade = 'A'));

-- E. Find all courses offered in the morning hours (i.e., courses ending before 13:00)

-- Some duplicates
SELECT *
FROM course
    WHERE course_id IN (SELECT course_id FROM section
    WHERE time_slot_id IN
(SELECT DISTINCT (time_slot_id) FROM time_slot WHERE end_hr < 13));

-- With no duplicatess
SELECT *
FROM course
    WHERE course_id NOT IN (SELECT course_id FROM section
    WHERE time_slot_id IN (select DISTINCT(time_slot_id) FROM time_slot WHERE end_hr >= 13));