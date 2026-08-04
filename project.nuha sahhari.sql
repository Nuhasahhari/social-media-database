-- 1 Write a SQL query to display every post along with the username of its author, the total number of likes, and the total number of comments.

SELECT p.post_id,p.caption, u.username,
    COUNT(DISTINCT pl.user_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments
FROM post p
JOIN users u
ON p.user_id = u.user_id
LEFT JOIN post_likes pl
ON p.post_id = pl.post_id
LEFT JOIN comments c
ON p.post_id = c.post_id
GROUP BY p.post_id, p.caption, u.username;
-- 2 Write a SQL query to find all users who have never created a post.
SELECT u.user_id , u.username
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM post p
    WHERE p.user_id = u.user_id
);
-- 3 Write a SQL query to find the five users whose posts have received the highest total number of likes.
SELECT u.user_id, u.username,
       COUNT(pl.user_id) AS total_likes
FROM users u
INNER JOIN post p
ON u.user_id = p.user_id
LEFT JOIN post_likes pl
ON p.post_id = pl.post_id
GROUP BY u.user_id, u.username
ORDER BY total_likes DESC
LIMIT 5;
-- 4 Write a SQL query to display the latest post created by each user, including the username, post caption, location, and creation date.
SELECT u.username, p.caption, p.location, p.created_at
FROM users u
JOIN post p
ON u.user_id = p.user_id
WHERE p.created_at =
(
SELECT MAX(created_at)
FROM post p2
WHERE p2.user_id = u.user_id
);
-- 5 Write a SQL query to find users whose number of followers is greater than the average follower count of all users.
SELECT u.user_id, u.username,
    COUNT(f.follower_id) AS followers
FROM users u
LEFT JOIN follows f
ON u.user_id = f.followee_id
GROUP BY u.user_id, u.username
HAVING followers >
(
    SELECT AVG(follower_count)
    FROM (
        SELECT COUNT(*) AS follower_count
        FROM follows
        GROUP BY followee_id
    ) AS avg_followers
);
-- 6 Write a SQL query to find the post or posts that have received the highest number of likes.
SELECT p.post_id,
       p.caption,
       COUNT(pl.user_id) AS total_likes
FROM post p
JOIN post_likes pl
ON p.post_id = pl.post_id
GROUP BY p.post_id, p.caption
ORDER BY total_likes DESC;

SELECT p.post_id, p.caption,
    COUNT(pl.user_id) AS total_likes
FROM post p
JOIN post_likes pl
ON p.post_id = pl.post_id
GROUP BY p.post_id, p.caption
HAVING total_likes =
(
    SELECT MAX(likes_count)
    FROM (
        SELECT COUNT(*) AS likes_count
        FROM post_likes
        GROUP BY post_id
    ) AS total_likes
);
-- 7  Write a SQL query to find hashtags that have been used in at least three different posts. Display each hashtag, the number of posts using it, and the number of users following it.
SELECT h.hashtag_name,
       COUNT(DISTINCT pt.post_id) AS total_posts,
       COUNT(DISTINCT hf.user_id) AS total_followers
FROM hashtags h
JOIN post_tags pt
ON h.hashtag_id = pt.hashtag_id
LEFT JOIN hashtag_follow  hf
ON h.hashtag_id = hf.hashtag_id
GROUP BY h.hashtag_id, h.hashtag_name
HAVING COUNT(DISTINCT pt.post_id) >= 3;

-- 8  Write a SQL query to find users who bookmarked a post that they also liked. Display the username, post ID, and post caption.
SELECT u.username, p.post_id,p.caption
FROM users u
JOIN bookmarks bm
ON u.user_id = bm.user_id
JOIN post_likes pl
ON bm.user_id = pl.user_id
AND bm.post_id = pl.post_id
JOIN post p
ON bm.post_id = p.post_id;
-- 9 write a SQL query to find comments that have received more likes than the average number of likes received by all comments.
SELECT ct.comment_id, ct.comment_text,
       COUNT(cl.user_id) AS total_likes
FROM comments ct
LEFT JOIN comment_likes cl
ON ct.comment_id = cl.comment_id
GROUP BY ct.comment_id, ct.comment_text
HAVING COUNT(cl.user_id) >
(
    SELECT AVG(likes_count)
    FROM
    (
        SELECT COUNT(cl.user_id) AS likes_count
        FROM comments ct
        LEFT JOIN comment_likes cl
        ON ct.comment_id = cl.comment_id
        GROUP BY ct.comment_id
    ) AS average_table
);
-- 10 Write a SQL query to find pairs of users who follow each other. Display each pair only once.

SELECT u1.username AS user1, u2.username AS user2
FROM follows f1
JOIN follows f2
ON f1.follower_id = f2.followee_id
AND f1.followee_id = f2.follower_id
JOIN users u1
ON f1.follower_id = u1.user_id
JOIN users u2
ON f1.followee_id = u2.user_id
WHERE f1.follower_id < f1.followee_id;
-- 11 Which hashtag has the highest number of followers in the social media database? (Give me the first 5 ones).
SELECT h.hashtag_name,
       COUNT(hf.user_id) AS followers_count
FROM hashtags h
JOIN hashtag_follow hf
ON h.hashtag_id = hf.hashtag_id
GROUP BY h.hashtag_id, h.hashtag_name
ORDER BY followers_count DESC
LIMIT 5;
--  12 What are the most frequently used hashtags in the social media database? (Give me the used for all hashtags and determine which one is the most).
SELECT h.hashtag_name,
       COUNT(pt.post_id) AS used_hashtag
FROM hashtags h
LEFT JOIN post_tags pt
ON h.hashtag_id = pt.hashtag_id
GROUP BY h.hashtag_id, h.hashtag_name
ORDER BY used_hashtag DESC;
-- 13 Who is the most inactive user (or the user with the least activity) in the social media database? (Give me the first 5 and determine which one is the least).
SELECT u.user_id, u.username,
       COUNT(p.post_id) AS total_posts
FROM users u
LEFT JOIN post p
ON u.user_id = p.user_id
GROUP BY u.user_id, u.username
ORDER BY total_posts ASC
LIMIT 5;
-- 14 Which posts have received the highest number of likes in the social media database?
SELECT p.post_id,
       COUNT(pl.user_id) AS total_likes
FROM post p
LEFT JOIN post_likes pl
ON p.post_id = pl.post_id
GROUP BY p.post_id
ORDER BY total_likes DESC;

-- 15 What is the average number of posts per user in the social media database?
SELECT AVG(post_count) AS average_posts
FROM (
    SELECT user_id,
           COUNT(post_id) AS post_count
    FROM post
    GROUP BY user_id
) AS avg_post;

-- 16 How many times has each user logged in to the social media platform?
SELECT u.user_id, u.username,
       COUNT(l.login_id) AS login_count
FROM users u
LEFT JOIN login l
ON u.user_id = l.user_id
GROUP BY u.user_id, u.username
ORDER BY login_count DESC;
--  17 Are there any users who have liked every single post in the social media database?

SELECT u.user_id, u.username
FROM users u
INNER JOIN post_likes pl
ON u.user_id = pl.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT pl.post_id) =
(
    SELECT COUNT(*)
    FROM post
);
-- 18 What is the location of each user in the social media database?
SELECT distinct u.user_id, u.username , p.location 
FROM users u 
INNER JOIN post p 
on u.user_id = p.user_id; 
-- 19  What is the location of each post , time of creation, and number of the likes ?
SELECT p.post_id, p.location, p.created_at,
    (
        SELECT COUNT(*)
        FROM post_likes pl
        WHERE pl.post_id = p.post_id
    ) AS total_likes
FROM post p;
-- 20 Write a SQL query to display the user who has bookmarked the largest number of different posts.

SELECT u.user_id, u.username,
    COUNT(DISTINCT b.post_id) AS total_bookmarks
FROM users u
JOIN bookmarks b
ON u.user_id = b.user_id
GROUP BY u.user_id, u.username
ORDER BY total_bookmarks DESC
LIMIT 1;


-- 21 Write a SQL query to display the average number of likes received per post for each user.

SELECT u.user_id, u.username,
    AVG(post_likes_count) AS average_likes
FROM users u
JOIN
(
    SELECT
        p.user_id,
        p.post_id,
        COUNT(pl.user_id) AS post_likes_count
    FROM post p
    LEFT JOIN post_likes pl
    ON p.post_id = pl.post_id
    GROUP BY p.post_id, p.user_id
) AS t
ON u.user_id = t.user_id
GROUP BY u.user_id, u.username;
-- 22 Display the total number of followers and followings for each user.
SELECT
    u.user_id, u.username,
    COUNT(DISTINCT f1.follower_id) AS total_followers,
    COUNT(DISTINCT f2.followee_id) AS total_followings
FROM users u
LEFT JOIN follows f1
ON u.user_id = f1.followee_id
LEFT JOIN follows f2
ON u.user_id = f2.follower_id
GROUP BY u.user_id, u.username;

-- 23 Write a SQL query to display each user along with the total number of photos and videos they have posted.

SELECT u.user_id, u.username,
    COUNT(DISTINCT ph.photo_id) AS total_photos,
    COUNT(DISTINCT v.video_id) AS total_videos
FROM users u
LEFT JOIN post p
ON u.user_id = p.user_id
LEFT JOIN photos ph
ON p.post_id = ph.post_id
LEFT JOIN videos v
ON p.post_id = v.post_id
GROUP BY u.user_id, u.username;
-- 24 Rank users by the number of posts they created.
SELECT
    user_id,
    total_posts,
    RANK() OVER(
        ORDER BY total_posts DESC
    ) AS post_rank
FROM
(
    SELECT
        user_id,
        COUNT(*) AS total_posts
    FROM post
    GROUP BY user_id
) AS t;
-- 25 Write a SQL query to rank posts based on the number of likes

SELECT p.post_id, p.caption,
    COUNT(pl.user_id) AS total_likes,
    RANK() OVER (ORDER BY COUNT(pl.user_id) DESC) AS like_rank
FROM post p
LEFT JOIN post_likes pl
ON p.post_id = pl.post_id
GROUP BY p.post_id, p.caption;


-- 26 Write a SQL query to assign a row number to posts ordered by creation date.

SELECT
    post_id, caption, created_at,
    ROW_NUMBER() OVER (ORDER BY created_at DESC) AS row_num
FROM post;

-- 27 Write a SQL query to display the latest post of each user

SELECT *
FROM (
    SELECT
        u.username,
        p.caption,
        p.created_at,
        ROW_NUMBER() OVER(PARTITION BY u.user_id ORDER BY p.created_at DESC) AS rn
    FROM users u
    JOIN post p
    ON u.user_id = p.user_id
) t
WHERE rn = 1;
-- 28 Display each post with its order for each user.

SELECT post_id, user_id,
    created_at,
    ROW_NUMBER() OVER(
        PARTITION BY user_id
        ORDER BY created_at
    ) AS post_number
FROM post;


