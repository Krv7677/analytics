create database ABC;
USE ABC;
 
create index userindex on usergameplaydata(`User ID`);

/*Final Loyalty Point Formula
Loyalty Point = (0.01 * deposit) + (0.005 * Withdrawal amount) + (0.001 * (maximum of (#deposit - #withdrawal) or 0)) + (0.2 * Number of games played)

At the end of each month total loyalty points are alloted to all the players. Out of which the top 50 players are provided cash benefits. */
 
SELECT 
    0.01 * d.amount + 0.005 * w.amount + 0.001 * (d.amount - w.amount) + 0.2 * u.`Games Played` AS loyality_point
FROM
    depositdata d
        JOIN
    withdrawaldata w ON d.User_ID = w.`User ID`
        JOIN
    usergameplaydata u ON w.`User ID` = u.`User ID`
ORDER BY loyality_point DESC
LIMIT 50;

# adding required columns 

ALTER TABLE usergameplaydata
add month_name varchar(40),
add loyalty_points int not null,
add dates date,
ADD timeslot VARCHAR(50), 
ADD slots VARCHAR(50); 

ALTER TABLE usergameplaydata # changing colomn data type
MODIFY COLUMN  `Datetime` datetime;

UPDATE usergameplaydata 
SET 
    `Datetime` = STR_TO_DATE(`Datetime`, '%d-%m-%Y %H:%i');

insert into usergameplaydata(loyalty_points) select 0.01*d.amount+0.005*w.amount+0.001*(d.amount-w.amount)+0.2*u.`Games Played` 
from depositdata d join withdrawaldata w on d.User_ID= w.`User ID` join usergameplaydata u on w.`User ID`=u.`User ID`;

insert into usergameplaydata(month_name) SELECT MONTHNAME(dates) AS month_name
FROM usergameplaydata;


UPDATE usergameplaydata 
SET 
    dates = DATE(`Datetime`);

UPDATE usergameplaydata 
SET 
    slots = CASE
        WHEN
            HOUR(timeslot) >= 0
                AND HOUR(timeslot) < 12
        THEN
            's1'
        WHEN
            HOUR(timeslot) >= 12
                OR HOUR(timeslot) = 0
        THEN
            's2'
        ELSE 'na'
    END;

SELECT 
    *
FROM
    usergameplaydata
WHERE
    slots = 's2';

/* 1. Find Playerwise Loyalty points earned by Players in the following slots:-
    a. 2nd October Slot S1
    b. 16th October Slot S2
    b. 18th October Slot S1
    b. 26th October Slot S2 */

SELECT 
    A.*
FROM
    (SELECT 
        d.amount AS deposit,
            w.amount AS withdrawal,
            u.`Games Played` AS games_played,
            0.01 * d.amount + 0.005 * w.amount + 0.001 * (d.amount - w.amount) + 0.2 * u.`Games Played` AS loyality_point
    FROM
        depositdata d
    JOIN withdrawaldata w ON d.User_ID = w.`User ID`
    JOIN usergameplaydata u ON w.`User ID` = u.`User ID`
    WHERE
        dates = 2022 - 10 - 02 AND slots = 's1'
    ORDER BY u.`User ID` DESC) AS A 
UNION SELECT 
    B.*
FROM
    (SELECT 
        d.amount AS deposit,
            w.amount AS withdrawal,
            u.`Games Played` AS games_played,
            0.01 * d.amount + 0.005 * w.amount + 0.001 * (d.amount - w.amount) + 0.2 * u.`Games Played` AS loyality_point
    FROM
        depositdata d
    JOIN withdrawaldata w ON d.User_ID = w.`User ID`
    JOIN usergameplaydata u ON w.`User ID` = u.`User ID`
    WHERE
        dates = 2022 - 10 - 16 AND slots = 's2'
    ORDER BY u.`User ID` DESC) AS B 
UNION SELECT 
    C.*
FROM
    (SELECT 
        d.amount AS deposit,
            w.amount AS withdrawal,
            u.`Games Played` AS games_played,
            0.01 * d.amount + 0.005 * w.amount + 0.001 * (d.amount - w.amount) + 0.2 * u.`Games Played` AS loyality_point
    FROM
        depositdata d
    JOIN withdrawaldata w ON d.User_ID = w.`User ID`
    JOIN usergameplaydata u ON w.`User ID` = u.`User ID`
    WHERE
        dates = 2022 - 10 - 18 AND slots = 's1'
    ORDER BY u.`User ID` DESC) AS C 
UNION SELECT 
    D.*
FROM
    (SELECT 
        d.amount AS deposit,
            w.amount AS withdrawal,
            u.`Games Played` AS games_played,
            0.01 * d.amount + 0.005 * w.amount + 0.001 * (d.amount - w.amount) + 0.2 * u.`Games Played` AS loyality_point
    FROM
        depositdata d
    JOIN withdrawaldata w ON d.User_ID = w.`User ID`
    JOIN usergameplaydata u ON w.`User ID` = u.`User ID`
    WHERE
        dates = 2022 - 10 - 26 AND slots = 's2'
    ORDER BY u.`User ID` DESC) AS D;
    
    
SELECT 
    *
FROM
    usergameplaydata
ORDER BY loyalty_points DESC;

/* 2. Calculate overall loyalty points earned and rank players on the basis of loyalty points in the month of October. 
     In case of tie, number of games played should be taken as the next criteria for ranking*/
     
select `User ID`, loyalty_points,
row_number() over w as player_rank
from usergameplaydata 
where month_name='October' 
window w as (order by loyalty_points,`Games Played` desc);

/* What is the average deposit amount?*/

SELECT 
    AVG(amount) AS avg_deposit_amount
FROM
    depositdata;

/*  What is the average deposit amount per user in a month? */
UPDATE depositdata 
SET 
    `Datetime` = STR_TO_DATE(`Datetime`, '%d-%m-%Y %H:%i');

SELECT 
    MONTHNAME(`datetime`) AS month_name,
    AVG(amount) AS avg_deposit_amount_per_user
FROM
    depositdata
GROUP BY month_name;

SELECT 
    *
FROM
    depositdata;

/* What is the average number of games played per user?*/


SELECT 
    `User Id`, AVG(`Games Played`) AS avg_gamesplayed
FROM
    usergameplaydata
GROUP BY `User Id`
ORDER BY avg_gamesplayed DESC;

SELECT 
    `User Id` AS player, loyalty_points
FROM
    usergameplaydata
ORDER BY loyalty_points DESC
LIMIT 50;

/* bonus should be given according loyalty points, the player with highest loyalty points should receive the highest bonus amount,
 and follow the reducing corresponding to allocate bonus to  plyer with lowest loyalty points recieve lowest bouns. */
