-- Пункт 3. Запросы

/* a. Составной многотабличный запрос с CASE-выражением */

SELECT p.last_name, p.name, p.patronymic, t.carriage, rwt.carriage_count,
    CASE
        WHEN rwt.carriage_count % 2 != 0 AND rwt.carriage_count / 2 + 1 = t.carriage
            THEN 'СЕРЕДИНА'
        WHEN t.carriage <= rwt.carriage_count / 2
            THEN 'ближе к ГОЛОВЕ'
        ELSE 'ближе к ХВОСТУ'
    END
    AS carriage_position
FROM passenger AS p, ticket AS t, railway_trip AS rwt
    WHERE p.id = t.passenger_id AND t.railway_trip_id = rwt.id;

/* b. Многотабличный VIEW с возможностью его обновления */ --исправить

DROP VIEW IF EXISTS ticket_view;
CREATE OR REPLACE VIEW ticket_view
            (
             "Номер билета", "Фамилия", "Имя", "Отчество", "Паспорт", "Поезд", "А", "Отправление", "В",
             "Прибытие", "Вагон", "Место", "Цена", "Бельё", "Страховка", "Тариф", "Класс", "Категория льготы")
AS
SELECT tt.number,
       p.last_name,
       p.name,
       p.patronymic,
       p.passport,
       tr.number,
       tt.departure_point,
       tt.departure_date_time,
       tt.destination_point,
       tt.arrival_date_time,
       tt.carriage,
       tt.seat,
       tt.price,
       tff.bed_linen,
       tff.insurance,
       tff_dscr.description,
       s.class,
       dc.category
FROM ticket AS tt
         JOIN passenger AS p ON p.id = tt.passenger_id
         JOIN railway_trip AS rwt ON tt.railway_trip_id = rwt.id
         JOIN train AS tr ON rwt.train_id = tr.id
         JOIN tariff AS tff ON tt.tariff_id = tff.id
         JOIN tariff_description AS tff_dscr ON tff.description_id = tff_dscr.id
         JOIN service_class AS s ON tff.service_class_id = s.id
         JOIN discount_category dc on tff.discount_category_id = dc.id;

DROP FUNCTION IF EXISTS update_ticket_view();
CREATE OR REPLACE FUNCTION update_ticket_view() RETURNS TRIGGER AS
    $$
    BEGIN
        UPDATE passenger SET last_name = NEW."Фамилия",
                             name = NEW."Имя", patronymic = NEW."Отчество",
                             passport = NEW."Паспорт"
            WHERE id = (SELECT passenger_id FROM ticket WHERE ticket.number = OLD."Номер билета");
        UPDATE train SET number = NEW."Поезд"
            WHERE id = (SELECT train_id FROM railway_trip
            WHERE id = (SELECT railway_trip_id FROM ticket WHERE ticket.number = OLD."Номер билета"));
        UPDATE tariff_description SET description = NEW."Тариф"
            WHERE id = (SELECT description_id FROM tariff
            WHERE id = (SELECT tariff_id FROM ticket WHERE ticket.number = OLD."Номер билета"));
        UPDATE service_class SET class = NEW."Класс"
            WHERE id = (SELECT service_class_id FROM tariff
            WHERE id = (SELECT tariff_id FROM ticket WHERE ticket.number = OLD."Номер билета"));
        UPDATE discount_category SET category = NEW."Категория льготы"
            WHERE id = (SELECT discount_category_id FROM tariff
            WHERE id = (SELECT tariff_id FROM ticket WHERE ticket.number = OLD."Номер билета"));
        UPDATE tariff SET bed_linen = NEW."Бельё",
                          insurance = NEW."Страховка"
            WHERE id = (SELECT tariff_id FROM ticket WHERE ticket.number = OLD."Номер билета");
        UPDATE ticket SET departure_date_time = NEW."Отправление",
                          arrival_date_time = NEW."Прибытие",
                          carriage = NEW."Вагон",
                          seat = NEW."Цена"
            WHERE number = OLD."Номер билета";
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_update_ticket_view ON ticket_view;
CREATE TRIGGER tr_update_ticket_view INSTEAD OF UPDATE ON ticket_view
    FOR EACH ROW EXECUTE PROCEDURE update_ticket_view();
/* Проверка работоспособнсоти обновления представления
SELECT * FROM ticket_view;
UPDATE ticket_view SET name = 'NEW_NAME' WHERE ticket_number = 1;
SELECT * FROM ticket_view;
 */

/* c. Запросы, содержащие подзапрос в разделах SELECT, FROM и WHERE (в каждом хотя бы по одному) */

-- Пассажиры, имеющие билет с отправлением из Санкт-Петербурга (подзапрос в SELECT)

SELECT departure_point,
       destination_point,
       departure_date_time,
       arrival_date_time,
       (SELECT last_name
        FROM passenger
        WHERE id = ticket.passenger_id) AS last_name,
       (SELECT name
        FROM passenger
        WHERE id = ticket.passenger_id) AS name
FROM ticket
WHERE departure_point = 'Санкт-Петербург';

-- Пассажиры, чьи билеты стоят дешевле 3000р (подзапрос в FROM)
SELECT *
FROM (SELECT last_name, name, patronymic, price
      FROM passenger
          JOIN ticket  ON id = passenger_id) AS ticket
WHERE price < 3000;

-- Пассажиры, оплатившие страховку при покупке билета (подзапрос в WHERE)
SELECT last_name, name, patronymic
FROM passenger
WHERE id IN (SELECT passenger_id
             FROM ticket
             WHERE tariff_id IN (SELECT id FROM tariff WHERE insurance = TRUE));

/* d. Коррелированные подзапросы (минимум 3 запроса) */

-- Пассажиры, у которых есть бесплатный билет
SELECT last_name, name, patronymic
FROM passenger
WHERE id IN (SELECT passenger_id
             FROM ticket
             WHERE passenger.id = passenger_id
               AND price = 0);

-- Пассажиры, которые имеют билеты на определённую дату
SELECT departure_point,
       destination_point,
       departure_date_time,
       (SELECT last_name FROM passenger WHERE id = passenger_id),
       (SELECT name FROM passenger WHERE id = passenger_id),
       (SELECT passport FROM passenger WHERE id = passenger_id),
       (SELECT birth_certificate FROM passenger WHERE id = passenger_id)
FROM ticket
WHERE departure_date_time BETWEEN '2021-07-22 00:00' AND '2021-07-22 23:59';

-- Поезда, которые входят в категори "Скоростные"
SELECT id, number
FROM train
WHERE EXISTS(SELECT id
             FROM train_designation
             WHERE designation = 'Скоростные'
               AND train.designation_id = train_designation.id);

/* e. Многотабличный запрос, содержащий группировку записей,
   агрегатные функции и параметр, используемый в разделе HAVING */

-- Пассажиры, которые потратили на билеты больше 3000р
SELECT p.last_name, p.name, p.patronymic, SUM(t.price) AS sum
FROM ticket AS t
    JOIN passenger AS p ON t.passenger_id = p.id
GROUP BY p.last_name, p.name, p.patronymic
HAVING SUM(t.price) > 3000
ORDER BY sum;

/* f. Запросы, содержащий предикат ANY(SOME) или ALL (для каждого предиката) */

-- Пассажиры и их траты на билеты с ненулевой ценой (предикат ANY)
SELECT last_name, name, patronymic, price
FROM ticket
         JOIN passenger ON passenger_id = id
WHERE price > ANY (SELECT price FROM ticket);

-- Поезда, которые не входят в категорю "Скорые круглогодичного обращения"
SELECT number, departure_point, destination_point
FROM train
WHERE id != ALL (SELECT t.id
                 FROM train AS t
                     JOIN train_designation AS td ON t.designation_id = td.id
                 WHERE td.designation = 'Скорые круглогодичного обращения');