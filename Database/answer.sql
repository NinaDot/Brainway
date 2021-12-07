/*1). Выберите список всех комментариев, созданных пользователем с идентификатором 1. 
Поля для вывода: id, created_at, offer_id, comment_text.*/

SELECT id, created_at, offer_id, comment_text 
FROM comments 
WHERE user_id=1 

/*2) Выведите список объявлений (id, created_at, user_id, offer_type, title, price, picture), 
опубликованных в октябре 2021 года с сортировкой по дате публикации от самых свежих к более поздним. 
Дату публикации выведите в формате ‘DD.MM.YYYY’.*/

SELECT id, to_char(created_at, 'DD.MM.YYYY'), user_id, offer_type, title, price, picture
FROM offers
WHERE created_at > 01.10.2021
ORDER BY created_at ASC

/*3) Выберите список пользователей, которые ещё не опубликовали ни одного объявления. 
Поля для вывода: идентификатор пользователя, email, дата регистрации, имя и фамилия одной строкой как ‘user_name’. 
Отсортируйте по возрастанию даты регистрации.*/

SELECT id, email, created_at,  concat (first_name, ‘ ’, last_name)
FROM users LEFT JOIN offers
     ON users.id = offers.user_id
WHERE offers.user_id is NULL
ORDER BY created_at ASC

/*4) Выберите среди всех объявлений на продажу самые дорогие товары, их количество динамическое и заранее неизвестно.
Выведите их идентификаторы, автора (имя, фамилия), заголовки и цену продажи. */

SELECT offers.id, users.first_name, users.last_name, offers.title, offers.price
FROM offers INNER JOIN users
ON offers.user_id=users.id
WHERE offers.price = (
		SELECT MAX(price)
		FROM offers
);
ORDER BY offers.price DESC  

/*5) Для вывода на сайте выберите список всех категорий, в которых есть хотя бы одно объявление с указанием количества объявлений по каждой категории.
 Выведите id категории, title, slug, количество объявлений (offer_amount).*/

SELECT category_offer.category_id, categories.title, categories.slug, COUNT(category_id) AS offer_amount
FROM category_offer INNER JOIN categories
ON category_offer.category_id=categories.id
WHERE category_offer.offer_id is not NULL  




