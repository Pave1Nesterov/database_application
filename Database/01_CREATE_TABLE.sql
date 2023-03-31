/* Пункт 1. Создание таблиц */

DROP TABLE IF EXISTS passenger CASCADE; -- информация о пассажире
CREATE TABLE passenger
(
    id                SERIAL PRIMARY KEY,
    last_name         VARCHAR(31) NOT NULL,                           -- фамилия
    name              VARCHAR(31) NOT NULL,                           -- имя
    patronymic        VARCHAR(31),                                    -- отчество
    sex               CHAR(1)     NOT NULL CHECK (sex IN ('М', 'Ж')), -- пол
    date_of_birth     DATE        NOT NULL,                           -- дата рождения
    passport          VARCHAR(10) UNIQUE,                             -- серия и номер паспорта;
    country_code      CHAR(4)     NOT NULL,                           -- код государства выдачи
    email             VARCHAR(63) UNIQUE,                             -- электронная почта
    phone_number      VARCHAR(20) UNIQUE,                             -- номер телефона
    birth_certificate VARCHAR(20) UNIQUE,                             -- свидетельство о рождении
    CONSTRAINT documents_is_ok
        CHECK ((passport != '' AND birth_certificate = '' AND
                (phone_number != '' OR email != '' AND email LIKE '_%@_%._%'))
            OR (passport = '' AND birth_certificate != '' AND phone_number = '' AND email = ''))
);


DROP TABLE IF EXISTS train_designation CASCADE;
CREATE TABLE train_designation
(
    id          SERIAL PRIMARY KEY,
    designation VARCHAR(255) UNIQUE NOT NULL -- обозначение/категория
);


DROP TABLE IF EXISTS train CASCADE; -- общая информация о позде
CREATE TABLE train
(
    id                  SERIAL PRIMARY KEY,
    number              VARCHAR(6) UNIQUE NOT NULL, -- номер поезда
    designation_id      INTEGER           NOT NULL, -- id обозначения/категории
    departure_point     VARCHAR(31)       NOT NULL, -- начальная точка маршрута
    destination_point   VARCHAR(31)       NOT NULL, -- конечная точка маршрута
    departure_time      TIME              NOT NULL, -- время отправления
    arrival_time        TIME              NOT NULL, -- время прибытия
    travel_time_days    INTEGER DEFAULT 0 NOT NULL, -- время в пути (дней) - весь маршрут
    travel_time_hours   INTEGER DEFAULT 0 NOT NULL, -- время в пути (часов) - весь маршрут
    travel_time_minutes INTEGER DEFAULT 0 NOT NULL, -- время в пути (минут) - весь маршрут
    CONSTRAINT fk_train_designation FOREIGN KEY (designation_id) REFERENCES train_designation
        ON DELETE CASCADE ON UPDATE CASCADE
);


DROP TABLE IF EXISTS railway_trip CASCADE; -- общая информация о конкретном рейсе
CREATE TABLE railway_trip
(
    id               SERIAL PRIMARY KEY,
    train_id         INTEGER NOT NULL,           -- id поезда
    carriage_count   INTEGER NOT NULL DEFAULT 15
        CHECK (carriage_count BETWEEN 5 AND 20), -- количество вагонов в составе
    passengers_count INTEGER NOT NULL DEFAULT 0, -- общее количество пассажиров
    CONSTRAINT fk_railway_trip_id_train FOREIGN KEY (train_id) REFERENCES train
        ON DELETE CASCADE ON UPDATE CASCADE
);


DROP TABLE IF EXISTS service_class CASCADE;
CREATE TABLE service_class
(
    id    SERIAL PRIMARY KEY,
    class VARCHAR(31) UNIQUE NOT NULL -- класс занимаемого места
);


DROP TABLE IF EXISTS discount_category CASCADE;
CREATE TABLE discount_category
(
    id       SERIAL PRIMARY KEY,
    category VARCHAR(63) UNIQUE NOT NULL -- категория льготы
);


DROP TABLE IF EXISTS tariff_description CASCADE;
CREATE TABLE tariff_description
(
    id          SERIAL PRIMARY KEY,
    description VARCHAR(31) UNIQUE NOT NULL -- тариф
);


DROP TABLE IF EXISTS tariff CASCADE; -- общая информация о тарифе
CREATE TABLE tariff
(
    id                   SERIAL PRIMARY KEY,
    description_id       INTEGER NOT NULL,                                           -- id тарифа
    service_class_id     INTEGER NOT NULL CHECK (service_class_id BETWEEN 1 AND 11), -- id класса занимаемого места
    bed_linen            BOOLEAN NOT NULL DEFAULT FALSE,                             -- наличие оплаченного постельного белья
    insurance            BOOLEAN NOT NULL DEFAULT FALSE,                             -- наличие страховки
    discount_category_id INTEGER NOT NULL DEFAULT 1,                                 -- id категории льготы
    CONSTRAINT fk_tariff_description FOREIGN KEY (description_id) REFERENCES tariff_description
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tariff_service_class FOREIGN KEY (service_class_id) REFERENCES service_class
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tariff_discount_category FOREIGN KEY (discount_category_id) REFERENCES discount_category
        ON DELETE CASCADE ON UPDATE CASCADE
);


DROP TABLE IF EXISTS ticket CASCADE; -- общая информация о билете
CREATE TABLE ticket
(
    number              SERIAL PRIMARY KEY,                                     -- номер билета
    passenger_id        INTEGER     NOT NULL,                                   -- id пассажира
    railway_trip_id     INTEGER     NOT NULL,                                   -- id рейса/поездки
    tariff_id           INTEGER     NOT NULL,                                   -- id тарифа
    departure_point     VARCHAR(31) NOT NULL,                                   -- пункт отправления
    destination_point   VARCHAR(31) NOT NULL,                                   -- пункт прибытия
    departure_date_time TIMESTAMP   NOT NULL,                                   -- дата и время отправления
    arrival_date_time   TIMESTAMP   NOT NULL,                                   -- дата и время прибытия
    carriage            INTEGER     NOT NULL CHECK (carriage BETWEEN 1 AND 19), -- вагон
    seat                INTEGER     NOT NULL CHECK (seat BETWEEN 1 AND 64),     -- место
    price               INTEGER     NOT NULL DEFAULT 0 CHECK (price >= 0),      -- цена билета
    CONSTRAINT fk_ticket_passenger FOREIGN KEY (passenger_id) REFERENCES passenger
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_railway_trip FOREIGN KEY (railway_trip_id) REFERENCES railway_trip
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_tariff FOREIGN KEY (tariff_id) REFERENCES tariff
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (passenger_id, railway_trip_id, tariff_id, departure_point, destination_point, departure_date_time,
            arrival_date_time)
);


-- Пункт 4. Индексы

DROP EXTENSION IF EXISTS pg_trgm CASCADE;
CREATE EXTENSION pg_trgm; -- расширешие для использования индексов типа GIN

SELECT * FROM pg_indexes WHERE tablename = 'train'; -- вывод всех индексов таблицы

DROP INDEX IF EXISTS idx_lastname_name_patronymic;
CREATE INDEX idx_lastname_name_patronymic ON passenger(LOWER(last_name), LOWER(name), LOWER(patronymic));
DROP INDEX IF EXISTS idx_departure_point_destination_point;
CREATE INDEX idx_departure_point_destination_point ON ticket USING gin(departure_point gin_trgm_ops, destination_point gin_trgm_ops);
DROP INDEX IF EXISTS idx_departure_arrival_date_time;
CREATE INDEX idx_departure_arrival_date_time ON ticket(departure_date_time, arrival_date_time);
DROP INDEX IF EXISTS idx_passenger_id;
CREATE INDEX idx_passenger_id ON ticket(passenger_id);
DROP INDEX IF EXISTS idx_train_id;
CREATE INDEX idx_train_id ON railway_trip(train_id);
DROP INDEX IF EXISTS idx_train_number;
CREATE INDEX idx_train_number ON train(number);

/*SET enable_seqscan = false; -- отключение поиска полным перебором
EXPLAIN ANALYSE SELECT * FROM passenger WHERE last_name = 'шевченко' AND name = 'наталья';
EXPLAIN ANALYSE SELECT * FROM ticket WHERE departure_point = 'Сызрань';
EXPLAIN ANALYSE SELECT * FROM ticket WHERE departure_date_time = '2021-07-22 15:30';
SET enable_seqscan = default;*/

------------------------------------------------------------------------------------------------------------------------
/* Вспомогательные представления (для работы клиента) */

-- Представления таблиц

DROP VIEW IF EXISTS tariff_description_view;
CREATE OR REPLACE VIEW tariff_description_view(id, "Описание") AS
SELECT id, description FROM tariff_description;

DROP VIEW IF EXISTS service_class_view;
CREATE OR REPLACE VIEW service_class_view(id, "Класс") AS
SELECT id, class FROM service_class;

DROP VIEW IF EXISTS discount_category_view;
CREATE OR REPLACE VIEW discount_category_view(id, "Категория") AS
SELECT id, category FROM discount_category;

DROP VIEW IF EXISTS train_designation_view;
CREATE OR REPLACE VIEW train_designation_view(id, "Тип поезда") AS
SELECT id, designation FROM train_designation;

DROP VIEW IF EXISTS railway_trip_view;
CREATE OR REPLACE VIEW railway_trip_view("Номер рейса","Поезд","Кол-во вагонов","Кол-во пассажиров") AS
SELECT rt.id, t.number, carriage_count, passengers_count
FROM railway_trip AS rt
    JOIN train AS t ON rt.train_id = t.id;

DROP VIEW IF EXISTS train_view;
CREATE OR REPLACE VIEW train_view
            (id, "Номер поезда", "Тип", "А", "В", "Время отправления",
             "Время прибытия", "Время в пути: Дни", "Часы", "Минуты") AS
SELECT t.id, number, td.designation, departure_point, destination_point, departure_time,
       arrival_time, travel_time_days, travel_time_hours, travel_time_minutes
FROM train AS t
    JOIN train_designation AS td ON t.designation_id = td.id;

DROP VIEW IF EXISTS tariff_view;
CREATE OR REPLACE VIEW tariff_view(id, "Описание","Класс","Постельное бельё","Страховка","Категория льготы") AS
SELECT t.id, td.description, sc.class, bed_linen, insurance, dc.category
FROM tariff AS t
    JOIN tariff_description AS td ON t.description_id = td.id
    JOIN service_class AS sc ON t.service_class_id = sc.id
    JOIN discount_category AS dc ON t.discount_category_id = dc.id;

DROP VIEW IF EXISTS passenger_view;
CREATE OR REPLACE VIEW passenger_view
            (id, "Фамилия", "Имя", "Отчество", "Пол", "Дата рождения", "Паспорт", "Код страны выдачи", "Почта",
             "Телефон", "Свидетельство о рождении")
as
SELECT passenger.id,
       passenger.last_name         AS "Фамилия",
       passenger.name              AS "Имя",
       passenger.patronymic        AS "Отчество",
       passenger.sex               AS "Пол",
       passenger.date_of_birth     AS "Дата рождения",
       passenger.passport          AS "Паспорт",
       passenger.country_code      AS "Код страны выдачи",
       passenger.email             AS "Почта",
       passenger.phone_number      AS "Телефон",
       passenger.birth_certificate AS "Свидетельство о рождении"
FROM passenger;

DROP VIEW IF EXISTS ticket_view_main;
CREATE OR REPLACE VIEW ticket_view_main ("Номер билета", "Фамилия", "Имя", "Отчество", "Поезд", "Кол-во вагонов",
    "Кол-во пассажиров", "Тариф", "Класс", "Бельё", "Страховка", "Категория льготы", "А", "Отправление", "В",
    "Прибытие", "Вагон", "Место", "Цена") AS
SELECT tt.number,
       p.last_name,
       p.name,
       p.patronymic,
       tr.number,
       rwt.carriage_count,
       rwt.passengers_count,
       tff_dscr.description,
       s.class,
       tff.bed_linen,
       tff.insurance,
       dc.category,
       tt.departure_point,
       tt.departure_date_time,
       tt.destination_point,
       tt.arrival_date_time,
       tt.carriage,
       tt.seat,
       tt.price
FROM ticket AS tt
         JOIN passenger AS p ON p.id = tt.passenger_id
         JOIN railway_trip AS rwt ON tt.railway_trip_id = rwt.id
         JOIN train AS tr ON rwt.train_id = tr.id
         JOIN tariff AS tff ON tt.tariff_id = tff.id
         JOIN tariff_description AS tff_dscr ON tff.description_id = tff_dscr.id
         JOIN service_class AS s ON tff.service_class_id = s.id
         JOIN discount_category dc on tff.discount_category_id = dc.id;

-- Представления запросов (пункт 3)
DROP VIEW IF EXISTS q1_view;
CREATE OR REPLACE VIEW q1_view("Фамилия", "Имя", "Отчество", "Вагон", "Количество вагонов", "Позиция вагона") AS
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

DROP VIEW IF EXISTS q3_1_view;
CREATE OR REPLACE VIEW q3_1_view("Пункт отправления", "Пункт прибытия",
    "Время отправления", "Время прибытия","Фамилия", "Имя") AS
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

DROP VIEW IF EXISTS q3_2_view;
CREATE OR REPLACE VIEW q3_2_view("Фамилия", "Имя", "Отчество", "Цена") AS
SELECT *
FROM (SELECT last_name, name, patronymic, price
      FROM passenger
          JOIN ticket ON id = passenger_id) AS ticket
WHERE ticket.price < 3000;

DROP VIEW IF EXISTS q3_3_view;
CREATE OR REPLACE VIEW q3_3_view("Фамилия", "Имя", "Отчество") AS
SELECT last_name, name, patronymic
FROM passenger
WHERE id IN (SELECT passenger_id
             FROM ticket
             WHERE tariff_id IN (SELECT id FROM tariff WHERE insurance = TRUE));

DROP VIEW IF EXISTS q4_1_view;
CREATE OR REPLACE VIEW q4_1_view("Фамилия", "Имя", "Отчество") AS
SELECT last_name, name, patronymic
FROM passenger
WHERE EXISTS (SELECT passenger_id
             FROM ticket
             WHERE passenger.id = passenger_id
               AND price = 0);

DROP VIEW IF EXISTS q4_2_view;
CREATE OR REPLACE VIEW q4_2_view("Пункт отправления", "Пункт прибытия", "Дата и время отправления",
    "Фамилия", "Имя", "Паспорт", "Свидетельство о рождении") AS
SELECT departure_point,
       destination_point,
       departure_date_time,
       (SELECT last_name FROM passenger WHERE id = passenger_id),
       (SELECT name FROM passenger WHERE id = passenger_id),
       (SELECT passport FROM passenger WHERE id = passenger_id),
       (SELECT birth_certificate FROM passenger WHERE id = passenger_id)
FROM ticket
WHERE departure_date_time BETWEEN '2021-07-22 00:00' AND '2021-07-22 23:59';

DROP VIEW IF EXISTS q4_3_view;
CREATE OR REPLACE VIEW q4_3_view("Номер поезда") AS
SELECT number
FROM train
WHERE EXISTS(SELECT id
             FROM train_designation
             WHERE designation = 'Скоростные'
               AND train.designation_id = train_designation.id);

DROP VIEW IF EXISTS q5_view;
CREATE OR REPLACE VIEW q5_view("Фамилия", "Имя", "Отчество", "Потрачено (рублей)") AS
SELECT p.last_name, p.name, p.patronymic, SUM(t.price) AS sum
FROM ticket AS t
    JOIN passenger AS p ON t.passenger_id = p.id
GROUP BY p.last_name, p.name, p.patronymic
HAVING SUM(t.price) > 3000
ORDER BY sum;

DROP VIEW IF EXISTS q6_1_view;
CREATE OR REPLACE VIEW q6_1_view("Фамилия", "Имя", "Отчество", "Цена") AS
SELECT last_name, name, patronymic, price
FROM ticket
         JOIN passenger ON passenger_id = id
WHERE price > ANY (SELECT price FROM ticket);

DROP VIEW IF EXISTS q6_2_view;
CREATE OR REPLACE VIEW q6_2_view("Номер поезда", "Пункт отправления", "Пункт прибытия") AS
SELECT number, departure_point, destination_point
FROM train
WHERE id != ALL (SELECT t.id
                 FROM train AS t
                          JOIN train_designation AS td ON t.designation_id = td.id
                 WHERE td.designation = 'Скорые круглогодичного обращения');