/*The CS50 Duck has been stolen! The town of Fiftyville has called upon you to solve the mystery of the stolen duck. Authorities believe that the thief stole the duck and then, shortly afterwards, took a flight out of town with the help of an accomplice. Your goal is to identify:

Who the thief is,
What city the thief escaped to, and
Who the thief’s accomplice is who helped them escape
All you know is that the theft took place on July 28, 2021 and that it took place on Humphrey Street.*/

-- Keep a log of any SQL queries you execute as you solve the mystery.

--Checking schema
.schema

--Check crime scene reports for 28. July (2021) on Humphrey Street
SELECT description
FROM crime_scene_reports
WHERE year = '2021'
AND month = '7'
AND day = '28'
AND street = 'Humphrey Street';
/*Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery. Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery. Littering took place at 16:36. No known witnesses.*/

--Check bakery security logs for activity and license plates on 28. July(2021) 10:15
SELECT activity, license_plate
FROM bakery_security_logs
WHERE year = '2021'
AND month = '7'
AND day = '28'
AND hour = '10'
AND minute = '15';
--No results

--Check interviews for that day

SELECT transcript, name
FROM interviews
WHERE year = '2021'
AND month ='7'
AND day ='28';

/*
Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame. (Ruth)

I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money. (Eugene)

As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket. (Raymond)
*/


--Check bakery security logs for activity and license plates on 28. July(2021) 10:15-10:25
SELECT activity, license_plate
FROM bakery_security_logs
WHERE year = '2021'
AND month = '7'
AND day = '28'
AND hour = '10'
AND minute >= '15'
AND minute <= '25';

--Check for cars that left the bakery within 10 minutes of the theft
/*license plates from exiting cars
5P2BI95(Vanessa - 221103) - (725) 555-4692,
94KL13X(Barry-243696) - (301) 555-4174,
6P58WS2(Iman-396669) - (829) 555-5269,
4328GD8(Sofia-398010) - (130) 555-0289,
G412CB7(Luca-467400) - (389) 555-5198,
L93JTIZ(Diana-514354) - (770) 555-1861,
322W7JE(Kelsey-560886) - (499) 555-9472,
0NTHK55(Bruce-686048) - (367) 555-5533*/
SELECT id, name, phone_number
FROM people
WHERE license_plate = '5P2BI95'
OR license_plate = '94KL13X'
OR license_plate = '6P58WS2'
OR license_plate = '4328GD8'
OR license_plate = 'G412CB7'
OR license_plate = 'L93JTIZ'
OR license_plate = '322W7JE'
OR license_plate = '0NTHK55';

--Check the ATM for withdrawals from the thieves (Location = Leggett Street)
SELECT account_number
FROM atm_transactions
WHERE atm_location ='Leggett Street'
AND year='2021'
AND day='28'
AND month='7'
AND transaction_type = 'withdraw';
/* account numbers for withdrawals|
28500762,28296815,76054385,49610011,
16153065,25506511,81061156,26013199*/

--Crosscheck bank information on these accounts with people ID that were seen leaving the crime scene
SELECT person_id
FROM bank_accounts
WHERE account_number IN (28500762,28296815,76054385,49610011,16153065,25506511,81061156,26013199);

--Find the names of people who withdrew money at that time
SELECT name,
FROM people
WHERE id IN
(SELECT person_id
FROM bank_accounts
WHERE account_number IN (28500762,28296815,76054385,49610011,16153065,25506511,81061156,26013199))
AND people.name IN ('Vanessa', 'Barry', 'Iman', 'Sofia', 'Luca', 'Diana', 'Kelsey', 'Bruce');

--Check phone calls from the thief - find the accomplice (Duration: less than a minute)
--Check calls bellow 60 seconds for Iman Luca Diana and Bruce
SELECT receiver, caller
FROM phone_calls
WHERE caller IN ('(829) 555-5269','(389) 555-5198','(770) 555-1861','(367) 555-5533')
AND duration < 60
AND year = 2021
AND month = 7
AND day = 28;
--Diana called (725) 555-3243 and Bruce called (375) 555-8161 for less than a minute
--Get all information on Diana and Bruce
SELECT id, name, phone_number, passport_number
FROM people
WHERE name IN ('Diana', 'Bruce');
/*
+--------+-------+----------------+-----------------+--------------+-------------+
|   id   | name  |  phone_number  | passport_number |account number|license_plate|
+--------+-------+----------------+-----------------+--------------+-------------+
| 514354 | Diana | (770) 555-1861 | 3592750733      | 26013199     | L93JTIZ     |
| 686048 | Bruce | (367) 555-5533 | 5773159633      | 49610011     | 0NTHK55     |
+--------+-------+----------------+-----------------+--------------+-------------+
*/
--Get account number for Diana and Bruce
SELECT person_id, account_number
FROM bank_accounts
WHERE person_id IN
(SELECT id
FROM people
WHERE name IN ('Diana', 'Bruce'));

--Call from Diana
SELECT *
FROM phone_calls
WHERE caller = ('(770) 555-1861')
AND receiver = ('(725) 555-3243')
AND duration < 60;

--Call from Bruce
SELECT *
FROM phone_calls
WHERE caller = ('(367) 555-5533')
AND receiver = ('(375) 555-8161')
AND duration < 60;

--Check if Bruce or Diana are on any flights
SELECT flight_id
FROM passengers
WHERE passport_number
IN (SELECT passport_number FROM people WHERE name = 'Diana');
SELECT flight_id
FROM passengers
WHERE passport_number IN
(SELECT passport_number
FROM people
WHERE name = 'Bruce');

SELECT *
FROM flights
WHERE id IN
(SELECT flight_id
FROM passengers
WHERE passport_number IN
(SELECT passport_number
FROM people
WHERE name = 'Diana'));

SELECT *
FROM flights
WHERE id IN
(SELECT flight_id
FROM passengers
WHERE passport_number IN
(SELECT passport_number
FROM people
WHERE name = 'Bruce'));

--The thief went on the earliest flight - That is Bruce
--Find out who Bruce called
SELECT name FROM people WHERE phone_number = '(375) 555-8161';
--Accomplice is Robin

--Check where Bruce traveled to: destination airport id = 4
SELECT city FROM airports WHERE id = 4;
--Thief Bruce went to New York City