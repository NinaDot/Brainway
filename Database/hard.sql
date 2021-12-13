/*1) Выберите список объявлений, относящихся к категории “Дом”. 
Поля: название категории (category_name) и данные объявления (id, created_at, user_id, title, price). 
Список категорий для объявлений выводить не нужно.
Выведите следующие 4 объявления после первых 4.*/

SELECT offers.id, offers.created_at, offers.user_id, offers.title, offers.price, (SELECT title FROM categories WHERE title = "Дом") AS category_name
FROM offers JOIN category_offer
ON offer.id = category_offer.offer_id
JOIN categories
ON category_offer.category_id = categories.id
WHERE categories.title = "Дом"
LIMIT 5,4

/*2) Выведите объявления (id, title, user_id, offer_type, price) со всеми категориями, к которым оно относится, 
собранными в одну строку, например: “Спорт, Развлечения, Дети”. 
Назовите этот столбец categories. Отсортируйте по убыванию цены.
Выведите названия типов объявлений на русском: если тип buy, то нужно вывести “Куплю”, если sell - “Продам”, соответственно.*/

SELECT offers.id, offers.title, offers.user_id, offers.offer_type, offers.price, string_agg( categories.title, ',' ) AS categories
FROM offers JOIN category_offer
ON offer.id = category_offer.offer_id
JOIN categories
ON category_offer.category_id = categories.id
IF (offers.offer_type = 'buy', 'Куплю', IF(offer_type = 'sell', 'Продам', NULL))
ORDER BY price DESC

/*3) Выведите список пользователей (id, first_name, last_name, email), количество объявлений, 
созданных ими (offer_amount), и количество комментариев под этими объявлениями (comments_amount). 
Результат отсортируйте по убыванию  offer_amount.*/

SELECT users.id, users.first_name, users.last_name, users.email, COUNT(offers.user_id) AS offer_amount, COUNT(comments.offer_id) AS comments_amount
FROM users JOIN LEFT offers
ON users.id = offers.user_id
JOIN LEFT comments
ON offers.id = comments.offer_id
GROUP BY users.id, offers.id

/*4) Реализуйте запрос поиска: 
Выберите все объявления с типом “Куплю” (“buy”) в категории “Животные”, в заголовке которых есть слова “кролик” и “гараж” одновременно. 
Полный текст объявления обрежьте до 30 символов, добавьте к полученной строке “...” и назовите announce. 
Отберите объявления с ценой менее 50000.
Поля для вывода: идентификатор объявления, тип, заголовок, стоимость, автор (имя, фамилия),  анонс,  категория,*/

SELECT offers.id, offers.offer_type, offers.title, offers.price, categories.title, users.first_name, users.last_name, 
CAST(concat(
    SELECT offers.offer_type
    FROM offers JOIN category_offer
    ON offers.id = category_offer.offer_id
    JOIN categories
    ON category_offer.category_id = categories.id
    WHERE offers.offer_type = "buy" AND categories.title = "Животные" AND offers.title LIKE "кролик" + "гараж"
) + "..." AS announce AS varchar(30)),
FROM offers JOIN category_offer
    ON offers.id = category_offer.offer_id
    JOIN categories
    ON category_offer.category_id = categories.id
    JOIN users
    ON offers.user_id = users.id
WHERE offers.offer_type = "buy" AND  categories.title = "Животные" AND offers.title LIKE "кролик" + "гараж" AND offers.price < 50000


/*5) Напишите запрос, который по массиву идентификаторов категорий соберёт массив названий соответствующих категорий. 
Пример: на входе массив ARRAY[1, 2, 5, 7], на выходе  массив строк:{}*/

SELECT array_agg(title ORDER BY array_agg(id))
FROM categories
WHERE id = 1, 2, 5, 7

/*6) Соберите мини-отчёт: реализуйте выборку количества объявлений по месяцам 2021 года. 
Поля для вывода: year, monthname, offers_amount. 
Отсортируйте отчёт по месяцам по возрастанию.  */

SELECT YEAR(created_at) AS year, MONTH(created_at) AS monthname, count(id) AS offers_amount
FROM offers
    WHERE YEAR(created_at) = 2021
    GROUP BY monthname
    ORDER By monthname ASC

/*7) Реализуйте запрос из пункта 6 с добавлением нарастающего итога по месяцам. Те же столбцы + столбец offers_sum.*/

SELECT YEAR(created_at) AS year, MONTH(created_at) AS monthname, COUNT(id) AS offers_amount, SUM(COUNT(id)) over(rows between unbounded preceding and current row) AS offers_sum
FROM offers
    WHERE YEAR(created_at) = 2021
    GROUP BY monthname
    ORDER By monthname ASC

/*8) Соберите jsonb-массив всех комментариев для объявления с id 7. 
Каждый комментарий должен быть представлен jsonb-объектом со следующими данными: 
id комментария, текст, дата создания, id пользователя, создавшего комментарий, фамилия и имя одной строкой, ссылка на аватар.*/

SELECT jsonb_agg (SELECT comments.id, comments.comment_text, comments.created_at, comments.user_id, CONCAT(users.first_name + users.last_name), users.avatar
FROM comments JOIN LEFT users
ON comments.user_id = users.id
JOIN offers
ON comments.offer_id = offers.id
WHERE offers.id = 7
)

/*9) Создайте pl/pgsql-функцию, выполняющую запрос из п. 4.
Функция должна принимать набор параметров-фильтров для поиска.
Функция должна возвращать набор строк - список объявлений, соответствующих фильтрам.*/

CREATE FUNCTION search (integer) RETURNS SETOF character AS
SELECT offers.id, offers.offer_type, offers.title, offers.price, categories.title, users.first_name, users.last_name, 
CAST(concat(
    SELECT offers.offer_type
    FROM offers JOIN category_offer
    ON offers.id = category_offer.offer_id
    JOIN categories
    ON category_offer.category_id = categories.id
    WHERE offers.offer_type = "buy" AND categories.title = "Животные" AND offers.title LIKE "кролик" + "гараж"
) + "..." AS announce AS varchar(30)),
FROM offers JOIN category_offer
    ON offers.id = category_offer.offer_id
    JOIN categories
    ON category_offer.category_id = categories.id
    JOIN users
    ON offers.user_id = users.id
WHERE offers.offer_type = "buy" AND  categories.title = "Животные" AND offers.title LIKE "кролик" + "гараж" AND offers.price < 50000
LANGUAGE sql;


SELECT  first(10) AS list ;


