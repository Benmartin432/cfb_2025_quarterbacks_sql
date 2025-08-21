/* 
I created the schema cfb_qb_2025. I imported two tables that I created myself and exported to CSV files with data captured from ESPN. 

Today we're looking at the top 200 quarterbacks ranked on total yards for the season from college football in 2023 and 2024 to better predict 
who could be a breakout candiate for the 2025 season. The analysis is all statistical, not accounting for other factors like team situation, 
injury, or playing time. It doesn't account for those quarterbacks who started late in the season and therefore don't have a high amount in 
yardage. This is being completed for analysts to identify the best quarterbacks based on statistics regarding the highest yardage seasons in 
2023 and 2024, and then going from there. 

This will give them the opportunity to better focus in on who they see with their own eyes if the player's ability compares with the numbers.

** NOTE: Some of these quarterbacks are already in the NFL National Football League or not playing college football anymore, so their numbers 
will be compared for reference but not to be used to make the final decision of best college quarterbacks to watch out for in 2025. 

I'll be identifying the most likely hidden gems, plus players who are still worth watching to see if they can improve on their mistakes. I'll
call those players 'hidden gems' and '2nd chance', respectively.
*/

USE cfb_qb_2025;

SHOW TABLES;

SELECT *
FROM cfb_qb_stats_2024_full;

SELECT *
FROM cfb_qb_stats_2023;

/*
Looks like the tables were imported correctly. I purposefully didn't put the year column for the 2023 season when creating the tables,
so let's fix that here.

** NOTE: This is important because some quarterbacks will be listed on both tables since they played both seasons. 
Let's keep their entries separate.
*/

CREATE TABLE cfb_qb_stats_2023_full AS 
SELECT * FROM cfb_qb_stats_2023;

SELECT * 
FROM cfb_qb_stats_2023;

ALTER TABLE cfb_qb_stats_2023_full
ADD COLUMN `Year` CHAR(4);

SET SQL_SAFE_UPDATES = 0;

UPDATE cfb_qb_stats_2023_full
SET `Year` = 2023;

SELECT *
FROM cfb_qb_stats_2023_full;


/*
I created a duplicate table. Then I added the Year column. I disabled safe mode so that I would be able to update the table. Since 2023 was the 
year for every row, I set the value of year equal to it. I had to use backticks for Year since that is a function in MYSQL. Also I set the data 
type to CHAR(4) since I won't be changing the numbers and there were only 4 characters used.

I now want to combine the two tables and create a new one to run some queries on.
*/

CREATE TABLE cfb_qb_stats_all AS 
SELECT * 
FROM cfb_qb_stats_2023_full 
UNION ALL 
SELECT * 
FROM cfb_qb_stats_2024_full;

SELECT *
FROM cfb_qb_stats_all;

/*
Great, it worked. I now want to take out the RK rank column since it was ranked by yards per year, meaning there are two of each number,
and it shows nothing useful. Also, I'm going to drop the POS position since we are only looking at the quarterback position in this analysis. 
I will keep the TEAM team name since the quarterbacks may have changed schools from year to year. I do however want to give them a player id
since it'll be easier to reference in these queries.

Once complete, I'll start running the queries to answer some questions about the data.
*/

ALTER TABLE cfb_qb_stats_all
DROP COLUMN RK;

ALTER TABLE cfb_qb_stats_all
DROP COLUMN POS;

ALTER TABLE cfb_qb_stats_all
ADD COLUMN Player_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

DELETE FROM cfb_qb_stats_all
WHERE player_id IS NULL;

SELECT *
FROM cfb_qb_stats_all;




-- Queries and Analysis: 


-- Who had the most yards thrown on the season? Show the top 40.

SELECT Player_id, `NAME`, TEAM, YDS, `Year`
FROM cfb_qb_stats_all
ORDER BY YDS DESC
LIMIT 40;

/* 
Michael Penix Jr. 2023 had the most, by 124 yards more than the next one, but he's already a starting quarterback in the NFL. 

8 players had over 4,000 yards. The only quarterback still in college in that category includes Garrett Nussmeier. Josh Hoover 
and Carson Beck 2023 are just below that 4,000 mark. 

A lot of these top 30 are in the NFL but the ones that aren't include:

2024:
Garrett Nussmeier, 
Josh Hoover, 
Chandler Morris, 
Cade Klubnik, 
Rocco Becht,
Owen McCown,
Drew Allar

2023:
Davis Brin, 
Joey Aguilar, 
Jordan McCloud, 
Gunner Watson, 
Brayden Schager, 
Alan Bowman,
Brayden Fowler-Nicolosi,
TJ Finley,
Chandler Rogers,

Carson Beck was the only player listed in both years. 

That includes 17 players. These will be the ones we continue to uncover more information about with the MYSQL analysis.
*/


-- Who doesn't process the play correctly and makes the most mistakes? Show the top 8. Rank by INT, show SACK to compare, allowing ties.


WITH most_int AS (
	SELECT Player_id, `NAME`, TEAM, `INT`, SACK, `Year`,
			DENSE_RANK() OVER (ORDER BY `INT` DESC) AS most_int_rank
	FROM cfb_qb_stats_all
)
SELECT *
FROM most_int
WHERE most_int_rank <= 8
ORDER BY most_int_rank, `INT`, `Name`;

/*
I used a CTE to order by the most interceptions in a season, including both 2023 and 2024, ranking by most to least, including ties, and includes the most int
to at least 9 int thrown.

Davis Brin 2023 had the most with 19. The next highest player has 16, 3 less than him. He also had 31 sacks, meaning even
though he threw for a lot of yards in the previous query, he was also very reckless with the ball. Let's take him off of the list.

The next notable name from the ones listed in the most passing yards query includes Brayden Fowler-Nicolosi. He had 16 int, which is tied for the
second highest int. Though he only had 12 sacks, so we need to see how his Year 2024 compares. Which he is on this list again, but at 9 int and
9 sacks for 2024. That's a huge improvement, especially for the int. He'll be someone to watch, let's put him on the hidden gem list.

Alan Bowman 2023 had 14 int which is very high, though he only had 7 sacks, so it is noteworthy to keep him in the running for a hidden gem. 
If he can make better decisions with his throws, he could be someone to watch. However one important thing to note, this was from 2023, 
so what happened in 2024 for him? It looks like his makes this list twice, at 12 int but still only 8 sacks. Looks like he didn't improve,
but the sack numbers are still low enough. Let's put him in the 2nd chance list.

The next name is Brayden Schager 2023. He had 14 int and a high amount of 39 sacks. Looks like Brayden Schager is listed again for 2024 with
similar numbers of 13 int and 39 sacks. He made no progress from his bad year and is very reckless, let's take him off the list too.

Joey Aguilar 2024 had 14 int and 15 sacks, and in 2023 had 10 int and 19 sacks. Since 2023 was his best year, it looks like his descision making
got worse the next year, but still within a reasonable range. Let's put him in the 2nd chance list.

Jordan McCloud had 13 int and 17 sacks in 2024, though his notable passing yards season was in 2023, which that year he produced 10 int and
23 sacks. So he made worse decisions put didn't hold as long onto the ball. Because he didn't really improve, let's put him on the 2nd chance list.

Carson Beck had 12 int and 18 sacks in 2024 but didn't make this list for 2023. Was it a down year?

Chandler Morris 2024 had 12 int and 12 sacks in his high passing yards year, meaning he probably was throwing a lot. We'll need more information.

Garrett Nussmeier had 12 int and 16 sacks in 2024, more information needed.

Josh Hoover 2024 had 11 int and 16 sacks, then had 9 int and 8 sacks in 2023. Looks like he got worse year over year, so I'll move him 
to the 2nd chance list.

Owen McCown 2024 had 10 int and 27 sacks, more information needed.

Cade Klubnik 2023 had 9 int and 28 in 2023, though his better year was 2024, so I'll make a note to see more on that.

Rocco Becht 2024 had 9 int and 15 sacks, more information needed.


I didn't see these names listed, so I will go ahead and run a query to double check to see if I missed any:

2024:
Drew Allar

2023:
Gunner Watson, 
TJ Finley,
Chandler Rogers
*/

SELECT `NAME`, TEAM, `INT`, SACK, `YEAR`
FROM cfb_qb_stats_all
WHERE `NAME` LIKE 'Drew%'
	OR `NAME` LIKE 'Gunner%'
    OR `NAME` LIKE 'TJ%'
    OR `NAME` LIKE 'Chandler%';
    
/*
Drew Allar had an amazing only 2 int and but still 15 sacks in 2023 and 8 int and 19 sacks in 2024. He passed the int test, though he is just 
below the 9 int threshold, with 8 in 2024, and it looks like his had got worse year over year. Something to keep in mind.

Gunner Watson seems to have his information missing.

TJ Finley had 8 int and 29 sacks in 2023 and only 2 int and 2 sacks in 2024. That's either an amazing improvement or he got injured/benched. 

Chandler Rogers had only 5 int in 2023 but a lot of sacks of 33 in 2023, but no information for 2024.


So let me do some outside research to find this data since it's so small to better complete the analysis. 
Also, I need to see why Gunner Watson isn't showing up in the query at all now.
*/

SELECT Player_id, `NAME`, TEAM, YDS, `Year`
FROM cfb_qb_stats_all
ORDER BY YDS DESC
LIMIT 40;

SELECT *
FROM cfb_qb_stats_all
WHERE `Name` LIKE 'Gunnar%';

/*
I ran the original query again where Gunner Watson's name first appeared. Looks like I misspelled his name in my notes. 
It's Gunnar with an a, not an e. I searched for him specifically after and found he had 6 int and 24 sacks in 2023, 
but no information for 2024. Since I said I was going to do more research for these one-off cases, I'll put in the information here.


Gunnar Watson actually went undrafted to the NFL for the 2024 season. I'll take his name off of the list.

TJ Finley did get sidelined with an injury in the third game of the 2024 season.

Chandler Rogers was out of eligibility to play at the collegiate level in 2024, but he transferred to another school after that season so he
would be eligible to play again for his new team. I'll keep him in the analysis.


That was beneficial to do that extra research for the one-offs since there were only a few. It really shed some light on the confusion in the data, 
rather than putting a null or average value, or taking them off of the list completely.


Let's continue the analysis. Let's look at the touchdowns now.
*/


-- How about the most TDs in a season? Order by the most touchdowns, with at least 15 thrown. Rank them, no ties. 

WITH touchdowns AS (
	SELECT `NAME`, TD, `YEAR`,
		RANK() OVER(ORDER BY TD DESC) AS ranked_touchdowns
	FROM cfb_qb_stats_all
)
SELECT `NAME`, TD, `YEAR`, ranked_touchdowns
FROM touchdowns
WHERE TD >= 15
ORDER BY TD DESC;


/*
Bo Nix had the most with 45 TDs. He just completed a successful rookie campaign in the NFL. Jayden Daniels was listed 2nd with 40, and he just
won the rookie of the year award in the NFL in 2024. Cameron Ward was 3rd best with 39 and he got drafted first overall in the draft.
Knowing that, let's see how these college football players compare.

Cade Klubnik is tied for 5th best with 36 TDs in 2024. That puts him in good company.

Jordan McCloud is tied for 7th with 35 TDs in 2023. Even though he was put on the 2nd chance list, this shows that there is talent there, even if
he is streaky with his decision making. It also looks like for his 2024 season, he's ranked 16th overall. That shows real potential if he
can work on taking care of the football this season. I'll move him to the hidden gems list.

Joey Aguilar 2023 is 10th best. He had 33 TDs. So the potential is there for him as well but he will have to limit his mistakes. 

Chandler Morris 2024 is confirmed that he was throwing a lot with 31 TDs at 13th best. 

Garrett Nussmeier 2024 and Chadler Rogers 2023 are 20th best at 29 TDs, Rocco Becht 2024 and Owen McCown 2024 with 25 TDs at 38th, Carson
Beck 2023, TJ Finley 2023, and Drew Allar 2024 are all tied at 49th with 24 TDs. That rounds out the top 50 over those two seasons. 


Now I'll compare the TD-int ratio, plus add in who has a 3 TD to 1 int ratio, to show who is more productive than turning the ball over,
for the players potentially left in the hidden gems list. 
*/

WITH productive AS (
	SELECT `NAME`, TD, `INT`, `YEAR`
    FROM cfb_qb_stats_all
)
SELECT `NAME`, TD, `INT`, `YEAR`,
ROUND(TD/NULLIF(`INT`, 0), 2) AS td_int_ratio,
CASE 
	WHEN (`INT` = 0 AND TD > 0) OR TD >= 3 * `INT` THEN 1
		ELSE 0
	END AS ratio_3_to_1
FROM productive
ORDER BY td_int_ratio DESC;

/*
It looks like Drew Allar has the 2nd highest TD to int ratio with 12.50 in 2023. 

Cade Klubnik 2024 is at 6 to 1, with Chandler Rogers is right behind at 5.80. Garrett Nussmeier 2023 is next at 4.00, though I can see he actually
only threw 4 TDs and 1 int that season. Carson Beck 2023 is tied with him at 4.00, but with an actual season of 24 TDs to 6 int. Jordan McCloud
2023 at 3.50, Joey Aguilar 2023, TJ Finley 2023, and Drew Allar 2024 rounds out the list. That puts all of these guys as something to look out for.
If they aren't on the hidden gems list yet, and other categories align with potential, I'll put them there. Otherwise I'll put them on the 2nd
chance list since this is one of the most coveted statistics for a quarterback. 

Rocco Becht is just under 3.00 with 2.88 in 2023 and 2.78 in 2024. Even though he's below the threhold, that does show consistency.

Chandler Morris is at 2.58 for 2024. He's streaky, but worth a second look. Owen McCown is at 2.50 in 2024. 


So based on all this information let's show the list and update all of the players.

Hidden Gems:
Cade Klubnik, 
Drew Allar,
Jordan McCloud,
Brayden Fowler-Nicolosi,
Joey Aguilar, 
Garrett Nussmeier,
TJ Finley,
Rocco Becht,

2nd Chance:
Josh Hoover, 
Chandler Rogers,
Alan Bowman,
Owen McCown,
Chandler Morris, 
Carson Beck,

Off of the Lists (not good enough or ineligible):
Gunner Watson,
Brayden Schager,
Davis Brin, 

After completion, this shows the analysts who to watch out for more with the hidden gems list. Also, it's worth taking another look at the 2nd
chance list of players to see how their seasons progress. It provided a focused view on who to study with more intangibles that need to be analyzed.
Like an eye test, leadership, personality, off of the field behavior, etc. Also this analysis only looked at ESPN data for the last two seasons.
Teams who switched to an unproven quarterback were not considered here. Also if they didn't hit the threshold of minimum yards thrown in the season,
they were also not considered. It's worth going back to include those players, as well as looking at more statistics from other websites. Including
more statistics like rushing yards, rushing TDs, and fumbles can help put a more complete profile on the player. Also a more in-depth analysis
using the data like completion percentage and quarterback rating should be considered in the future. More ratios can be used to test how 
efficient a player really is. All in all, this gives a great starting point for NFL teams to watch some players that may have slipped through
the cracks to determine any hidden gems for the 2025 college football season. 
*/

/*
This analysis was completed by me, Benjamin Martin. The data comes from ESPN: https://www.espn.com/college-football/stats/player with the tables
made by me as well.
*/