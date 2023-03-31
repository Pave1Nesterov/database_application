/* Пункт 5. Триггер  обновления информации о кол-ве пассажиров на одном рейсе */

DROP FUNCTION IF EXISTS ticket_ins_upd_del() CASCADE;
CREATE OR REPLACE FUNCTION ticket_ins_upd_del() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        UPDATE railway_trip SET passengers_count = passengers_count - 1 WHERE id = OLD.railway_trip_id;
        RETURN OLD;
    ELSEIF (TG_OP = 'INSERT') THEN
        UPDATE railway_trip SET passengers_count = passengers_count + 1 WHERE id = NEW.railway_trip_id;
        RETURN NEW;
    ELSEIF (TG_OP = 'UPDATE') THEN
        UPDATE railway_trip SET passengers_count = passengers_count - 1 WHERE id = OLD.railway_trip_id;
        UPDATE railway_trip SET passengers_count = passengers_count + 1 WHERE id = NEW.railway_trip_id;
        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_ticket_ins_upd_del ON ticket;
CREATE TRIGGER tr_ticket_ins_upd_del AFTER INSERT OR UPDATE OR DELETE ON ticket
    FOR EACH ROW EXECUTE FUNCTION ticket_ins_upd_del();

-- Проверка работоспособности
/*
SELECT * FROM railway_trip ORDER BY id;
DELETE FROM ticket WHERE passenger_id = 27;
INSERT INTO ticket (passenger_id, railway_trip_id, tariff_id, departure_point, destination_point, departure_date_time, arrival_date_time, carriage, seat, price)
VALUES
    (27, 7, 3, 'Москва', 'Санкт-Петербург', '2021-07-21 15:30', '2021-07-21 19:15', 8, 19, 3100),
    (27, 3, 3, 'Санкт-Петербург', 'Москва', '2021-07-29 17:00', '2021-07-29 20:50', 5, 7, 2950);
UPDATE ticket SET price = 3200 WHERE passenger_id = 27 AND railway_trip_id = 7;
 */

/* Пункт 6. Операции добавления, удаления и обновления в виде хранимых процедур или функций с параметрами для всех таблиц */

DROP FUNCTION IF EXISTS insert_train_designation(_designation VARCHAR(255));
CREATE OR REPLACE FUNCTION insert_train_designation(_designation VARCHAR(255)) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка добавлена';
    count_value INTEGER = 0;
BEGIN
    IF (_designation IS NULL) THEN
        RAISE EXCEPTION 'Поле designation не может быть пустым!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM train_designation WHERE (designation = _designation);
    IF (count_value > 0) THEN
        RAISE EXCEPTION 'Строка с такими данными уже существует!';
    ELSE
        INSERT INTO train_designation(designation) VALUES (_designation);
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_train_designation(_id INTEGER, _new_designation VARCHAR(255));
CREATE OR REPLACE FUNCTION update_train_designation(_id INTEGER, _new_designation VARCHAR(255)) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка изменена';
    count_value INTEGER = 0;
BEGIN
    IF (_new_designation IS NULL) THEN
        RAISE EXCEPTION 'Поле designation не может быть пустым!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM train_designation WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        UPDATE train_designation SET designation = _new_designation WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_train_designation(_id INTEGER);
CREATE OR REPLACE FUNCTION delete_train_designation(_id INTEGER) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка удалена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM train_designation WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        DELETE FROM train_designation WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS insert_tariff_description(_description VARCHAR(31));
CREATE OR REPLACE FUNCTION insert_tariff_description(_description VARCHAR(31)) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка добавлена';
    count_value INTEGER = 0;
BEGIN
    IF (_description IS NULL) THEN
        RAISE EXCEPTION 'Поле _description не может быть пустым!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM tariff_description WHERE _description = description;
    IF (count_value > 0) THEN
        RAISE EXCEPTION 'Строка с такими данными уже существует!';
    ELSE
        INSERT INTO tariff_description(description) VALUES (_description);
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_tariff_description(_id INTEGER, _new_description VARCHAR(31));
CREATE OR REPLACE FUNCTION update_tariff_description(_id INTEGER, _new_description VARCHAR(31)) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка изменена';
    count_value INTEGER = 0;
BEGIN
    IF (_new_description IS NULL) THEN
        RAISE EXCEPTION 'Поле description не может быть пустым!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM tariff_description WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        UPDATE tariff_description SET description = _new_description WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_tariff_description(_id INTEGER);
CREATE OR REPLACE FUNCTION delete_tariff_description(_id INTEGER) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка удалена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM tariff_description WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        DELETE FROM tariff_description WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS insert_service_class(_class VARCHAR(31));
CREATE OR REPLACE FUNCTION insert_service_class(_class VARCHAR(31)) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка добавлена';
    count_value INTEGER = 0;
BEGIN
    IF (_class IS NULL) THEN
        RAISE EXCEPTION 'Поле _class не может быть пустым!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM service_class WHERE _class = class;
    IF (count_value > 0) THEN
        RAISE EXCEPTION 'Строка с такими данными уже существует!';
    ELSE
        INSERT INTO service_class(class) VALUES (_class);
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_service_class(_id INTEGER, _class VARCHAR(31));
CREATE OR REPLACE FUNCTION update_service_class(_id INTEGER, _class VARCHAR(31)) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка изменена';
    count_value INTEGER = 0;
BEGIN
    IF (_class IS NULL) THEN
        RAISE EXCEPTION 'Поле _class не может быть пустым!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM service_class WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        UPDATE service_class SET class = _class WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_service_class(_id INTEGER);
CREATE OR REPLACE FUNCTION delete_service_class(_id INTEGER) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка удалена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM service_class WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        DELETE FROM service_class WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS insert_discount_category(_category VARCHAR(63));
CREATE OR REPLACE FUNCTION insert_discount_category(_category VARCHAR(63)) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка добавлена';
    count_value INTEGER = 0;
BEGIN
    IF (_category IS NULL) THEN
        RAISE EXCEPTION 'Поле _category не может быть пустым!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM discount_category WHERE _category = category;
    IF (count_value > 0) THEN
        RAISE EXCEPTION 'Строка с такими данными уже существует!';
    ELSE
        INSERT INTO discount_category(category) VALUES (_category);
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_discount_category(_id INTEGER, _category VARCHAR(63));
CREATE OR REPLACE FUNCTION update_discount_category(_id INTEGER, _category VARCHAR(63)) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка изменена';
    count_value INTEGER = 0;
BEGIN
    IF (_category IS NULL) THEN
        RAISE EXCEPTION 'Поле _category не может быть пустым!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM discount_category WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        UPDATE discount_category SET category = _category WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_discount_category(_id INTEGER);
CREATE OR REPLACE FUNCTION delete_discount_category(_id INTEGER) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка удалена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM discount_category WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        DELETE FROM discount_category WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS insert_passenger(
    _last_name VARCHAR(31),
    _name VARCHAR(31),
    _patronymic VARCHAR(31),
    _sex VARCHAR(1),
    _date_of_birth DATE,
    _passport VARCHAR(10),
    _country_code CHAR(4),
    _email VARCHAR(63),
    _phone_number VARCHAR(20),
    _birth_certificate VARCHAR(20)
);
CREATE FUNCTION insert_passenger(
    _last_name VARCHAR(31),
    _name VARCHAR(31),
    _patronymic VARCHAR(31),
    _sex VARCHAR(1),
    _date_of_birth DATE,
    _passport VARCHAR(10),
    _country_code CHAR(4),
    _email VARCHAR(63),
    _phone_number VARCHAR(20),
    _birth_certificate VARCHAR(20)) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка добавлена';
    count_value INTEGER = 0;
BEGIN
    IF (
            _last_name IS NULL OR _name IS NULL OR _sex IS NULL OR
            _date_of_birth IS NULL OR _country_code IS NULL
        ) THEN
        RAISE EXCEPTION 'Некоторые поля не могут быть пустыми!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM passenger
    WHERE last_name = _last_name
      AND name = _name
      AND patronymic = _patronymic
      AND sex = _sex
      AND date_of_birth = _date_of_birth
      AND passport = _passport
      AND country_code = _country_code
      AND email = _email
      AND phone_number = _phone_number
      AND birth_certificate = _birth_certificate;
    IF (count_value > 0) THEN
        RAISE EXCEPTION 'Строка с такими данными уже существует!';
    ELSE
        INSERT INTO passenger (last_name, name, patronymic, sex,
                               date_of_birth, passport,
                               country_code, email, phone_number, birth_certificate)
        VALUES (_last_name, _name, _patronymic, _sex,
                _date_of_birth, _passport,
                _country_code, _email, _phone_number, _birth_certificate);
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_passenger
(
    _id INTEGER,
    _last_name VARCHAR(31),
    _name VARCHAR(31),
    _patronymic VARCHAR(31),
    _sex VARCHAR(1),
    _date_of_birth DATE,
    _passport VARCHAR(10),
    _country_code CHAR(4),
    _email VARCHAR(63),
    _phone_number VARCHAR(20),
    _birth_certificate VARCHAR(20)
);
CREATE OR REPLACE FUNCTION update_passenger
(
    _id INTEGER,
    _last_name VARCHAR(31) DEFAULT NULL,
    _name VARCHAR(31) DEFAULT NULL,
    _patronymic VARCHAR(31) DEFAULT NULL,
    _sex VARCHAR(1) DEFAULT NULL,
    _date_of_birth DATE DEFAULT NULL,
    _passport VARCHAR(10) DEFAULT NULL,
    _country_code CHAR(4) DEFAULT NULL,
    _email VARCHAR(63) DEFAULT NULL,
    _phone_number VARCHAR(20) DEFAULT NULL,
    _birth_certificate VARCHAR(20) DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка изменена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM passenger WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        IF (_last_name IS NOT NULL) THEN
            UPDATE passenger SET last_name = _last_name WHERE _id = id;
        END IF;
        IF (_name IS NOT NULL) THEN
            UPDATE passenger SET name = _name WHERE _id = id;
        END IF;
        IF (_sex IS NOT NULL) THEN
            UPDATE passenger SET sex = _sex WHERE _id = id;
        END IF;
        IF (_date_of_birth IS NOT NULL) THEN
            UPDATE passenger SET date_of_birth = _date_of_birth WHERE _id = id;
        END IF;
        IF (_country_code IS NOT NULL) THEN
            UPDATE passenger SET country_code = _country_code WHERE _id = id;
        END IF;
        UPDATE passenger
        SET patronymic = _patronymic,
            passport = _passport,
            email = _email,
            phone_number = _phone_number,
            birth_certificate = _birth_certificate
        WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_passenger(_id INTEGER);
CREATE OR REPLACE FUNCTION delete_passenger(_id INTEGER) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка удалена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM passenger WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        DELETE FROM passenger WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS insert_train(
    _number VARCHAR(6),
    _designation_id INTEGER,
    _departure_point VARCHAR(31),
    _destination_point VARCHAR(31),
    _departure_time TIME,
    _arrival_time TIME,
    _travel_time_days INTEGER,
    _travel_time_hours INTEGER,
    _travel_time_minutes INTEGER
);
CREATE OR REPLACE FUNCTION insert_train(
    _number VARCHAR(6),
    _designation_id INTEGER DEFAULT NULL,
    _departure_point VARCHAR(31) DEFAULT NULL,
    _destination_point VARCHAR(31) DEFAULT NULL,
    _departure_time TIME DEFAULT NULL,
    _arrival_time TIME DEFAULT NULL,
    _travel_time_days INTEGER DEFAULT NULL,
    _travel_time_hours INTEGER DEFAULT NULL,
    _travel_time_minutes INTEGER DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка добавлена';
    count_value INTEGER = 0;
BEGIN
    IF (
            _number IS NULL OR _designation_id IS NULL OR _departure_point IS NULL OR
            _destination_point IS NULL OR _departure_time IS NULL OR _arrival_time IS NULL OR
            _travel_time_days IS NULL OR _travel_time_hours IS NULL OR _travel_time_minutes IS NULL
        ) THEN
        RAISE EXCEPTION 'Ни одно из полей не может быть пустым!';
    END IF;
    IF (NOT EXISTS(SELECT * FROM train_designation WHERE id = _designation_id)) THEN
        RAISE EXCEPTION 'Один из внешних ключей не имеет ссылки!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM train WHERE _number = number;
    IF (count_value > 0) THEN
        RAISE EXCEPTION 'Строка с такими данными уже существует!';
    ELSE
        INSERT INTO train (number, designation_id, departure_point, destination_point,
                           departure_time, arrival_time,
                           travel_time_days, travel_time_hours, travel_time_minutes)
        VALUES (_number, _designation_id, _departure_point, _destination_point,
                _departure_time, _arrival_time,
                _travel_time_days, _travel_time_hours, _travel_time_minutes);
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_train(
    _id INTEGER,
    _number VARCHAR(6),
    _designation_id INTEGER,
    _departure_point VARCHAR(31),
    _destination_point VARCHAR(31),
    _departure_time TIME,
    _arrival_time TIME,
    _travel_time_days INTEGER,
    _travel_time_hours INTEGER,
    _travel_time_minutes INTEGER
);
CREATE OR REPLACE FUNCTION update_train(
    _id INTEGER,
    _number VARCHAR(6) DEFAULT NULL,
    _designation_id INTEGER DEFAULT NULL,
    _departure_point VARCHAR(31) DEFAULT NULL,
    _destination_point VARCHAR(31) DEFAULT NULL,
    _departure_time TIME DEFAULT NULL,
    _arrival_time TIME DEFAULT NULL,
    _travel_time_days INTEGER DEFAULT NULL,
    _travel_time_hours INTEGER DEFAULT NULL,
    _travel_time_minutes INTEGER DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка изменена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM train WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        IF (_number IS NOT NULL) THEN
            UPDATE train SET number = _number WHERE _id = id;
        END IF;
        IF (_designation_id IS NOT NULL) THEN
            IF (NOT EXISTS(SELECT * FROM train_designation WHERE id = _designation_id)) THEN
                RAISE EXCEPTION 'Внешний ключ не имеет ссылки!';
            ELSE
                UPDATE train SET designation_id = _designation_id WHERE _id = id;
            END IF;
        END IF;
        IF (_departure_point IS NOT NULL) THEN
            UPDATE train SET departure_point = _departure_point WHERE _id = id;
        END IF;
        IF (_destination_point IS NOT NULL) THEN
            UPDATE train SET destination_point = _destination_point WHERE _id = id;
        END IF;
        IF (_departure_time IS NOT NULL) THEN
            UPDATE train SET departure_time = _departure_time WHERE _id = id;
        END IF;
        IF (_arrival_time IS NOT NULL) THEN
            UPDATE train SET arrival_time = _arrival_time WHERE _id = id;
        END IF;
        IF (_travel_time_days IS NOT NULL) THEN
            UPDATE train SET travel_time_days = _travel_time_days WHERE _id = id;
        END IF;
        IF (_travel_time_hours IS NOT NULL) THEN
            UPDATE train SET travel_time_hours = _travel_time_hours WHERE _id = id;
        END IF;
        IF (_travel_time_minutes IS NOT NULL) THEN
            UPDATE train SET travel_time_minutes = _travel_time_minutes WHERE _id = id;
        END IF;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_train(_id INTEGER);
CREATE OR REPLACE FUNCTION delete_train(_id INTEGER) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка удалена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM train WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        DELETE FROM train WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS insert_railway_trip
(
    _train_id INTEGER,
    _carriage_count INTEGER
);
CREATE OR REPLACE FUNCTION insert_railway_trip
(
    _train_id INTEGER,
    _carriage_count INTEGER
) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка добавлена';
BEGIN
    IF (_train_id IS NULL OR _carriage_count IS NULL) THEN
        RAISE EXCEPTION 'Ни одно из полей не может быть пустым!';
    END IF;
    IF (NOT EXISTS(SELECT * FROM train WHERE id = _train_id)) THEN
        RAISE EXCEPTION 'Внешний ключ не имеет ссылки';
    END IF;
    INSERT INTO railway_trip(train_id, carriage_count) VALUES (_train_id, _carriage_count);
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_railway_trip(_id INTEGER, _train_id INTEGER, _carriage_count INTEGER);
CREATE FUNCTION update_railway_trip
(
    _id INTEGER,
    _train_id INTEGER DEFAULT NULL,
    _carriage_count INTEGER DEFAULT NULL
) RETURNS TEXT AS
$$
DECLARE
    result      TEXT    = 'Строка изменена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM railway_trip WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        IF (_train_id IS NOT NULL) THEN
            IF (NOT EXISTS(SELECT * FROM train WHERE id = _train_id)) THEN
                RAISE EXCEPTION 'Внешний ключ не имеет ссылки!';
            ELSE
                UPDATE railway_trip SET train_id = _train_id WHERE _id = id;
            END IF;
        END IF;
        IF (_carriage_count IS NOT NULL) THEN
            UPDATE railway_trip SET carriage_count = _carriage_count WHERE _id = id;
        END IF;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_railway_trip(_id INTEGER);
CREATE OR REPLACE FUNCTION delete_railway_trip(_id INTEGER) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка удалена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM railway_trip WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        DELETE FROM railway_trip WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS insert_tariff
(
    _description_id INTEGER,
    _service_class_id INTEGER,
    _price REAL,
    _bed_linen BOOLEAN,
    _insurance BOOLEAN,
    _discount_category_id INTEGER
);
CREATE OR REPLACE FUNCTION insert_tariff
(
    _description_id INTEGER,
    _service_class_id INTEGER,
    _bed_linen BOOLEAN,
    _insurance BOOLEAN,
    _discount_category_id INTEGER
) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка добавлена';
    count_value INTEGER = 0;
BEGIN
    IF (_description_id IS NULL OR _service_class_id IS NULL
        OR _bed_linen IS NULL OR _insurance IS NULL) THEN
        RAISE EXCEPTION 'Некоторые поля не могут быть пустыми!';
    END IF;
    IF (NOT EXISTS(SELECT * FROM tariff_description WHERE id = _description_id) OR
        NOT EXISTS(SELECT * FROM service_class WHERE id = _service_class_id) OR
        NOT EXISTS(SELECT * FROM discount_category WHERE id = _discount_category_id))
    THEN
        RAISE EXCEPTION 'Один из внешних ключей не имеет ссылки!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM tariff
    WHERE description_id = _description_id
      AND service_class_id = _service_class_id
      AND bed_linen = _bed_linen
      AND insurance = _insurance
      AND discount_category_id = _discount_category_id;
    IF (count_value > 0) THEN
        RAISE EXCEPTION 'Строка с такими данными уже существует!';
    ELSE
        INSERT INTO tariff(description_id, service_class_id, bed_linen, insurance, discount_category_id)
        VALUES (_description_id, _service_class_id, _bed_linen, _insurance, _discount_category_id);
    END IF;
    RETURN result;
END;
$$LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_tariff
(
    _id INTEGER,
    _description_id INTEGER,
    _service_class_id INTEGER,
    _bed_linen BOOLEAN,
    _insurance BOOLEAN,
    _discount_category_id INTEGER
);
CREATE OR REPLACE FUNCTION update_tariff
(
    _id INTEGER,
    _description_id INTEGER DEFAULT NULL,
    _service_class_id INTEGER DEFAULT NULL,
    _bed_linen BOOLEAN DEFAULT NULL,
    _insurance BOOLEAN DEFAULT NULL,
    _discount_category_id INTEGER DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка изменена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM tariff WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        IF (_description_id IS NOT NULL) THEN
            IF (NOT EXISTS(SELECT * FROM tariff_description WHERE id = _description_id)) THEN
                RAISE EXCEPTION 'Один из внешних ключей не имеет ссылки!';
            ELSE
                UPDATE tariff SET description_id = _description_id WHERE _id = id;
            END IF;
        END IF;
        IF (_service_class_id IS NOT NULL) THEN
            IF (NOT EXISTS(SELECT * FROM service_class WHERE id = _service_class_id)) THEN
                RAISE EXCEPTION 'Один из внешних ключей не имеет ссылки!';
            ELSE
                UPDATE tariff SET service_class_id = _service_class_id WHERE _id = id;
            END IF;
        END IF;
        IF (_bed_linen IS NOT NULL) THEN
            UPDATE tariff SET bed_linen = _bed_linen WHERE _id = id;
        END IF;
        IF (_insurance IS NOT NULL) THEN
            UPDATE tariff SET insurance = _insurance WHERE _id = id;
        END IF;
        IF (_discount_category_id IS NOT NULL) THEN
            IF (NOT EXISTS(SELECT * FROM discount_category WHERE id = _discount_category_id)) THEN
                RAISE EXCEPTION 'Один из внешних ключей не имеет ссылки!';
            ELSE
                UPDATE tariff SET discount_category_id = _discount_category_id WHERE _id = id;
            END IF;
        END IF;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_tariff(_id INTEGER);
CREATE OR REPLACE FUNCTION delete_tariff(_id INTEGER) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка удалена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM tariff WHERE _id = id;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        DELETE FROM tariff WHERE _id = id;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS insert_ticket
(
    _passenger_id INTEGER,
    _railway_trip_id INTEGER,
    _tariff_id INTEGER,
    _departure_point VARCHAR(31),
    _destination_point VARCHAR(31),
    _departure_date_time TIMESTAMP,
    _arrival_date_time TIMESTAMP,
    _carriage INTEGER,
    _seat INTEGER,
    _price INTEGER
);
CREATE OR REPLACE FUNCTION insert_ticket
(
    _passenger_id INTEGER,
    _railway_trip_id INTEGER,
    _tariff_id INTEGER,
    _departure_point VARCHAR(31),
    _destination_point VARCHAR(31),
    _departure_date_time TIMESTAMP,
    _arrival_date_time TIMESTAMP,
    _carriage INTEGER,
    _seat INTEGER,
    _price INTEGER
) RETURNS TEXT AS $$
DECLARE
    result      TEXT    = 'Строка добавлена';
    count_value INTEGER = 0;
BEGIN
    IF (
            _passenger_id IS NULL OR _railway_trip_id IS NULL OR _tariff_id IS NULL OR
            _departure_point IS NULL OR _destination_point IS NULL OR
            _departure_date_time IS NULL OR _arrival_date_time IS NULL OR
            _carriage IS NULL OR _seat IS NULL OR _price IS NULL
        ) THEN
        RAISE EXCEPTION 'Ни одно из полей не может быть пустым!';
    END IF;
    IF (
            NOT EXISTS(SELECT * FROM passenger WHERE id = _passenger_id) OR
            NOT EXISTS(SELECT * FROM railway_trip WHERE id = _railway_trip_id) OR
            NOT EXISTS(SELECT * FROM tariff WHERE id = _tariff_id)
        )
    THEN
        RAISE EXCEPTION 'Один из внешних ключей не имеет ссылки!';
    END IF;
    SELECT COUNT(*) INTO count_value FROM ticket
    WHERE passenger_id = _passenger_id
      AND railway_trip_id = _railway_trip_id
      AND tariff_id = _tariff_id
      AND departure_point = _departure_point
      AND destination_point = _destination_point
      AND departure_date_time = _departure_date_time
      AND arrival_date_time = _arrival_date_time;
    IF (count_value > 0) THEN
        RAISE EXCEPTION 'Строка с такими данными уже существует!';
    ELSE
        INSERT INTO ticket (passenger_id, railway_trip_id, tariff_id,
                            departure_point, destination_point,
                            departure_date_time, arrival_date_time,
                            carriage, seat, price
                            )
        VALUES (
                _passenger_id, _railway_trip_id, _tariff_id,
                _departure_point, _destination_point,
                _departure_date_time, _arrival_date_time,
                _carriage, _seat, _price
                );
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_ticket
(
    _number INTEGER,
    _passenger_id INTEGER,
    _railway_trip_id INTEGER,
    _tariff_id INTEGER,
    _departure_point VARCHAR(31),
    _destination_point VARCHAR(31),
    _departure_date_time TIMESTAMP,
    _arrival_date_time TIMESTAMP,
    _carriage INTEGER,
    _seat INTEGER,
    _price INTEGER
);
CREATE OR REPLACE FUNCTION update_ticket
(
    _number INTEGER,
    _passenger_id INTEGER DEFAULT NULL,
    _railway_trip_id INTEGER DEFAULT NULL,
    _tariff_id INTEGER DEFAULT NULL,
    _departure_point VARCHAR(31) DEFAULT NULL,
    _destination_point VARCHAR(31) DEFAULT NULL,
    _departure_date_time TIMESTAMP DEFAULT NULL,
    _arrival_date_time TIMESTAMP DEFAULT NULL,
    _carriage INTEGER DEFAULT NULL,
    _seat INTEGER DEFAULT NULL,
    _price INTEGER DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    result TEXT    = 'Строка изменена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM ticket WHERE _number = number;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        IF (_passenger_id IS NOT NULL) THEN
            IF (NOT EXISTS(SELECT * FROM passenger WHERE id = _passenger_id)) THEN
                RAISE EXCEPTION 'Один из внешних ключей не имеет ссылки!';
            ELSE
                UPDATE ticket SET passenger_id = _passenger_id WHERE number = _number;
            END IF;
        END IF;
        IF (_railway_trip_id IS NOT NULL) THEN
            IF (NOT EXISTS(SELECT * FROM railway_trip WHERE id = _railway_trip_id)) THEN
                RAISE EXCEPTION 'Один из внешних ключей не имеет ссылки!';
            ELSE
                UPDATE ticket SET railway_trip_id = _railway_trip_id WHERE number = _number;
            END IF;
        END IF;
        IF (_tariff_id IS NOT NULL) THEN
            IF (NOT EXISTS(SELECT * FROM tariff WHERE id = _tariff_id)) THEN
                RAISE EXCEPTION 'Один из внешних ключей не имеет ссылки!';
            ELSE
                UPDATE ticket SET tariff_id = _tariff_id WHERE number = _number;
            END IF;
        END IF;
        IF (_departure_point IS NOT NULL) THEN
            UPDATE ticket SET departure_point = _departure_point WHERE _number = number;
        END IF;
        IF (_destination_point IS NOT NULL) THEN
            UPDATE ticket SET destination_point = _destination_point WHERE _number = number;
        END IF;
        IF (_departure_date_time IS NOT NULL) THEN
            UPDATE ticket SET departure_date_time = _departure_date_time WHERE _number = number;
        END IF;
        IF (_arrival_date_time IS NOT NULL) THEN
            UPDATE ticket SET arrival_date_time = _arrival_date_time WHERE _number = number;
        END IF;
        IF (_carriage IS NOT NULL) THEN
            UPDATE ticket SET carriage = _carriage WHERE _number = number;
        END IF;
        IF (_seat IS NOT NULL) THEN
            UPDATE ticket SET seat = _seat WHERE _number = number;
        END IF;
        IF (_price IS NOT NULL) THEN
            UPDATE ticket SET price = _price WHERE _number = number;
        END IF;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_ticket(_number INTEGER);
CREATE OR REPLACE FUNCTION delete_ticket(_number INTEGER) RETURNS TEXT AS $$
DECLARE
    result TEXT    = 'Строка удалена';
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value FROM ticket WHERE _number = number;
    IF (count_value = 0) THEN
        RAISE EXCEPTION 'Строка с таким id не найдена!';
    ELSE
        DELETE FROM ticket WHERE _number = number;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Пункт 7. Функция, состоящая из нескольких отдельных операций в виде единой
-- транзакции, которая при определенных условиях может быть зафиксирована или откатана;
DROP PROCEDURE IF EXISTS update_ticket_price(_ticket_number INTEGER);
CREATE OR REPLACE PROCEDURE update_ticket_price(_ticket_number INTEGER) AS $$
DECLARE
    a BOOLEAN;
BEGIN
    IF ((SELECT class
         FROM service_class AS sc
                  JOIN tariff AS tff ON tff.service_class_id = sc.id
                  JOIN ticket AS t ON t.tariff_id = tff.id
         WHERE t.number = _ticket_number) = 'Плацкарт') THEN
        UPDATE ticket SET price = price * 0.5 WHERE number = _ticket_number;
        a = TRUE;
    ELSE
        IF ((SELECT class
             FROM service_class AS sc
                      JOIN tariff AS tff ON tff.service_class_id = sc.id
                      JOIN ticket AS t ON t.tariff_id = tff.id
             WHERE t.number = _ticket_number) = 'Купе') THEN
            UPDATE ticket SET price = price * 0.75 WHERE number = _ticket_number;
            a = TRUE;
        ELSE
            a = FALSE;
            RAISE EXCEPTION 'Класс билета не соответствует требованиям';
        END IF;
    END IF;
    IF ((SELECT departure_date_time FROM ticket WHERE number = _ticket_number)
            BETWEEN '2022-05-09 00:00:00' AND '2022-05-09 23:59' AND a = TRUE) THEN
        COMMIT;
    ELSE
        ROLLBACK;
        RAISE EXCEPTION 'Билет не попадает на праздничный день!';
    END IF;
END;
$$ LANGUAGE plpgsql;

/* Проверка работоспособности
CALL update_ticket_price(1);
*/

-- Пункт 8. Курсор на обновления отдельных данных (вычисления значения полей выбранной таблицы)

DROP PROCEDURE IF EXISTS curs_update_discount_category(_id INTEGER, _category VARCHAR(63) );
CREATE OR REPLACE PROCEDURE curs_update_discount_category(_id INTEGER, _category VARCHAR(63)) AS $$
DECLARE
    cursor1 CURSOR FOR SELECT * FROM discount_category;
    d_id INTEGER;
    d_category VARCHAR(63);
BEGIN
    OPEN cursor1;
    LOOP
        FETCH cursor1 INTO d_id, d_category;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        IF (d_id = _id) THEN
            UPDATE discount_category
            SET category = _category
            WHERE CURRENT OF cursor1;
        END IF;
    END LOOP;
    CLOSE cursor1;
END;
$$ LANGUAGE plpgsql;

-- проверка курсора
/*CALL curs_update_discount_category(3, 'Пенсионеры');
SELECT * FROM discount_category;*/

-- Пункт 9. Реализовать собственную скалярную и векторную функции

-- Скалярная функция (просмотр количества купленных билетов по паспорту/свидетельству о рождении пассажира)
DROP FUNCTION IF EXISTS check_tickets_count(_document VARCHAR(20));
CREATE OR REPLACE FUNCTION check_tickets_count(_document VARCHAR(20))
    RETURNS INTEGER AS $$
DECLARE
    count_value INTEGER = 0;
BEGIN
    SELECT COUNT(*) INTO count_value
    FROM ticket
        JOIN passenger ON ticket.passenger_id = passenger.id
    WHERE passport = _document
       OR birth_certificate = _document;
    RETURN count_value;
END;
$$LANGUAGE plpgsql;
--Векторная функция (просмотр всех купленных билетов по документу поссажира)
DROP FUNCTION IF EXISTS check_tickets(_document VARCHAR);
CREATE OR REPLACE FUNCTION check_tickets(_document VARCHAR)
    RETURNS TABLE (number INTEGER, train VARCHAR(6), departure_point VARCHAR(31),
    departure_date_time TIMESTAMP, destination_point VARCHAR(31), arrival_date_time TIMESTAMP) AS $$
BEGIN
    RETURN QUERY SELECT ticket.number,
           train.number AS train_number,
           ticket.departure_point,
           ticket.departure_date_time,
           ticket.destination_point,
           ticket.arrival_date_time
    FROM ticket
             JOIN passenger AS p ON ticket.passenger_id = p.id
             JOIN railway_trip AS rt ON ticket.railway_trip_id = rt.id
             JOIN train ON rt.train_id = train.id
    WHERE passport = _document
       OR birth_certificate = _document;
END;
$$LANGUAGE plpgsql;

/* 3b. Многотабличный VIEW с возможностью его обновления */

DROP VIEW IF EXISTS ticket_view;
CREATE OR REPLACE VIEW ticket_view
            (
             "Номер билета", "Фамилия", "Имя", "Отчество", "Поезд", "А", "Отправление", "В",
             "Прибытие", "Вагон", "Место", "Цена", "Бельё", "Страховка")
AS
SELECT tt.number,
       p.last_name,
       p.name,
       p.patronymic,
       tr.number,
       tt.departure_point,
       tt.departure_date_time,
       tt.destination_point,
       tt.arrival_date_time,
       tt.carriage,
       tt.seat,
       tt.price,
       tff.bed_linen,
       tff.insurance
FROM ticket AS tt
         JOIN passenger AS p ON p.id = tt.passenger_id
         JOIN railway_trip AS rwt ON tt.railway_trip_id = rwt.id
         JOIN train AS tr ON rwt.train_id = tr.id
         JOIN tariff AS tff ON tt.tariff_id = tff.id;

/* Проверка работоспособнсоти обновления представления
SELECT * FROM ticket_view;
UPDATE ticket_view SET "Цена" = 1 WHERE "Номер билета" = 20;
SELECT * FROM ticket_view;
 */

-- Пункт 10. Распределение прав пользователей

DROP OWNED BY admin;
DROP ROLE IF EXISTS admin;
DROP OWNED BY moderator;
DROP ROLE IF EXISTS moderator;
DROP OWNED BY employee;
DROP ROLE IF EXISTS employee;
DROP OWNED BY moder_1;
DROP ROLE IF EXISTS moder_1;
DROP OWNED BY worker_1;
DROP ROLE IF EXISTS worker_1;

CREATE USER admin WITH PASSWORD 'admin' superuser createrole createdb;
CREATE ROLE moderator LOGIN;
CREATE ROLE employee LOGIN;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO moderator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO moderator;
GRANT INSERT, UPDATE, DELETE ON ticket, passenger, tariff, railway_trip, train TO moderator;
GRANT ALL PRIVILEGES ON ticket_view_main, ticket_view, passenger_view, tariff_description_view, service_class_view,
    discount_category_view, train_designation_view, train_view, railway_trip_view, tariff_view,
    q1_view, q3_1_view, q3_2_view, q3_3_view, q4_1_view, q4_2_view, q4_3_view, q5_view, q6_1_view, q6_2_view
    TO moderator;
GRANT SELECT ON ticket_view_main, passenger_view, tariff_description_view, service_class_view,
    discount_category_view, train_designation_view, train_view, railway_trip_view, tariff_view TO employee;

CREATE USER moder_1 WITH PASSWORD '123123';
CREATE USER worker_1 WITH PASSWORD '123';
GRANT moderator TO moder_1;
GRANT employee TO worker_1;

SELECT * FROM pg_user;

/*SELECT grantee, table_name, privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'ticket_view'
  AND privilege_type = 'SELECT';*/