DROP SCHEMA IF EXISTS plain CASCADE;
CREATE SCHEMA plain;
DROP SCHEMA IF EXISTS vroom CASCADE;
CREATE SCHEMA vroom;

DROP TABLE IF EXISTS plain.jobs;
DROP TABLE IF EXISTS plain.jobs_time_windows;
DROP TABLE IF EXISTS plain.shipments;
DROP TABLE IF EXISTS plain.shipments_time_windows;
DROP TABLE IF EXISTS plain.vehicles;
DROP TABLE IF EXISTS plain.breaks;
DROP TABLE IF EXISTS plain.breaks_time_windows;
DROP TABLE IF EXISTS plain.matrix;
DROP TABLE IF EXISTS vroom.jobs;
DROP TABLE IF EXISTS vroom.jobs_time_windows;
DROP TABLE IF EXISTS vroom.shipments;
DROP TABLE IF EXISTS vroom.shipments_time_windows;
DROP TABLE IF EXISTS vroom.vehicles;
DROP TABLE IF EXISTS vroom.breaks;
DROP TABLE IF EXISTS vroom.breaks_time_windows;
DROP TABLE IF EXISTS vroom.matrix;

-- JOBS TABLE start
CREATE TABLE plain.jobs (
  id BIGSERIAL PRIMARY KEY,
  location_id BIGINT,
  service INTEGER    DEFAULT 250,
  delivery BIGINT[],
  pickup BIGINT[],
  skills INTEGER[]   DEFAULT '{0}',
  priority INTEGER   DEFAULT 0
);

INSERT INTO plain.jobs
(location_id, delivery, pickup)
VALUES
(1, ARRAY[20], ARRAY[20]),
(2, ARRAY[30], ARRAY[30]),
(3, ARRAY[10], ARRAY[10]),
(3, ARRAY[40], ARRAY[40]),
(4, ARRAY[20], ARRAY[20]);
-- JOBS TABLE end


-- JOBS TIME WINDOWS TABLE start
CREATE TABLE plain.jobs_time_windows (
  id BIGINT REFERENCES plain.jobs(id),
  tw_open INTEGER,
  tw_close INTEGER
);

INSERT INTO plain.jobs_time_windows
(id, tw_open, tw_close)
VALUES
(1, 3625, 4375),
(2, 1250, 2000),
(3, 2725, 3475),
(4, 3525, 4275),
(5, 1025, 1775);
-- JOBS TIME WINDOWS TABLE end


-- SHIPMENTS TABLE start
CREATE TABLE plain.shipments (
  id BIGSERIAL PRIMARY KEY,
  p_location_id BIGINT,
  p_service INTEGER     DEFAULT 2250,
  d_location_id BIGINT,
  d_service INTEGER     DEFAULT 2250,
  amount BIGINT[],
  skills INTEGER[]      DEFAULT '{0}',
  priority INTEGER      DEFAULT 0
);

INSERT INTO plain.shipments
(p_location_id, d_location_id, amount)
VALUES
(3, 5, ARRAY[10]),
(5, 6, ARRAY[10]),
(1, 2, ARRAY[20]),
(1, 4, ARRAY[20]),
(2, 2, ARRAY[10]);
-- SHIPMENTS TABLE end


-- SHIPMENTS TIME WINDOWS TABLE start
CREATE TABLE plain.shipments_time_windows (
  id BIGINT REFERENCES plain.shipments(id),
  kind CHAR(1),
  tw_open INTEGER,
  tw_close INTEGER
);

INSERT INTO plain.shipments_time_windows
(id, kind, tw_open, tw_close)
VALUES
(1, 'p', 1625, 3650),
(1, 'd', 24925, 26700),
(2, 'p', 375, 1675),
(2, 'd', 4250, 5625),
(3, 'p', 15525, 17550),
(3, 'd', 20625, 21750),
(4, 'p', 6375, 8100),
(4, 'd', 8925, 10250),
(5, 'p', 13350, 15125),
(5, 'd', 18175, 19550);
-- SHIPMENTS TIME WINDOWS TABLE end


-- VEHICLES TABLE start
CREATE TABLE plain.vehicles (
  id BIGSERIAL PRIMARY KEY,
  start_id BIGINT,
  end_id BIGINT,
  capacity BIGINT[]    DEFAULT '{200}',
  skills INTEGER[]     DEFAULT '{0}',
  tw_open INTEGER,
  tw_close INTEGER   DEFAULT 30900,
  speed_factor FLOAT   DEFAULT 1.0,
  max_tasks INTEGER    DEFAULT 20
);

INSERT INTO plain.vehicles (start_id, end_id, tw_open)
VALUES
(1, 1, 0),
(1, 3, 100),
(1, 1, 0),
(3, 3, 0);
-- VEHICLES TABLE end


-- BREAKS TABLE start
CREATE TABLE plain.breaks (
  id BIGINT PRIMARY KEY,
  vehicle_id BIGINT REFERENCES plain.vehicles(id),
  service INTEGER
);

INSERT INTO plain.breaks
(id, vehicle_id, service)
VALUES
(1, 1,  0),
(2, 2, 10),
(3, 3,  0),
(4, 4,  0);
-- BREAKS TABLE end


-- BREAKS TIME WINDOWS TABLE start
CREATE TABLE plain.breaks_time_windows (
  id BIGINT REFERENCES plain.breaks(id),
  tw_open INTEGER,
  tw_close INTEGER
);

INSERT INTO plain.breaks_time_windows
(id, tw_open, tw_close)
  VALUES
(1, 250, 300),
(2, 250, 275),
(3, 0,     0),
(4, 250, 250);
-- BREAKS TIME WINDOWS TABLE end


-- MATRIX TABLE start
CREATE TABLE plain.matrix (
  start_id BIGINT,
  end_id BIGINT,
  duration INTEGER,
  cost INTEGER GENERATED ALWAYS AS (duration) STORED
);

INSERT INTO plain.matrix
(start_id, end_id, duration)
VALUES
(1, 1, 0), (1, 2, 50), (1, 3, 90), (1, 4, 75), (1, 5, 106), (1, 6, 127),
(2, 1, 50), (2, 2, 0), (2, 3, 125), (2, 4, 90), (2, 5, 145), (2, 6, 127),
(3, 1, 90), (3, 2, 125), (3, 3, 0), (3, 4, 50), (3, 5, 25), (3, 6, 90),
(4, 1, 75), (4, 2, 90), (4, 3, 50), (4, 4, 0), (4, 5, 75), (4, 6, 55),
(5, 1, 106), (5, 2, 145), (5, 3, 25), (5, 4, 75), (5, 5, 0), (5, 6, 111),
(6, 1, 127), (6, 2, 127), (6, 3, 90), (6, 4, 55), (6, 5, 111), (6, 6, 0);
-- MATRIX TABLE end


-- vroom JOBS TABLE start
CREATE TABLE vroom.jobs (
  id BIGSERIAL PRIMARY KEY,
  location_id BIGINT,
  service INTERVAL   DEFAULT '00:04:10',
  delivery BIGINT[],
  pickup BIGINT[],
  skills INTEGER[]   DEFAULT '{0}',
  priority INTEGER   DEFAULT 0
);

INSERT INTO vroom.jobs
(location_id, delivery, pickup)
VALUES
(1, ARRAY[20], ARRAY[20]),
(2, ARRAY[30], ARRAY[30]),
(3, ARRAY[10], ARRAY[10]),
(3, ARRAY[40], ARRAY[40]),
(4, ARRAY[20], ARRAY[20]);
-- vroom JOBS TABLE end


-- vroom JOBS TIME WINDOWS TABLE start
CREATE TABLE vroom.jobs_time_windows (
  id BIGINT REFERENCES vroom.jobs(id),
  tw_open TIMESTAMP,
  tw_close TIMESTAMP
);

INSERT INTO vroom.jobs_time_windows (id, tw_open, tw_close)
VALUES
(1, '2021-09-02 10:00:25', '2021-09-02 10:12:55'),
(2, '2021-09-02 09:20:50', '2021-09-02 09:33:20'),
(3, '2021-09-02 09:45:25', '2021-09-02 09:57:55'),
(4, '2021-09-02 09:58:45', '2021-09-02 10:11:15'),
(5, '2021-09-02 09:17:05', '2021-09-02 09:29:35');
-- vroom JOBS TIME WINDOWS TABLE end


-- vroom SHIPMENTS TABLE start
CREATE TABLE vroom.shipments (
  id BIGSERIAL PRIMARY KEY,
  p_location_id BIGINT,
  p_service INTERVAL    DEFAULT '00:37:30',
  d_location_id BIGINT,
  d_service INTERVAL    DEFAULT '00:37:30',
  amount BIGINT[],
  skills INTEGER[]      DEFAULT '{0}',
  priority INTEGER      DEFAULT 0
);

INSERT INTO vroom.shipments
(p_location_id, d_location_id, amount)
VALUES
(3, 5, ARRAY[10]),
(5, 6, ARRAY[10]),
(1, 2, ARRAY[20]),
(1, 4, ARRAY[20]),
(2, 2, ARRAY[10]);
-- vroom SHIPMENTS TABLE end


-- vroom SHIPMENTS TIME WINDOWS TABLE start
CREATE TABLE vroom.shipments_time_windows (
  id BIGINT REFERENCES vroom.shipments(id),
  kind CHAR(1),
  tw_open TIMESTAMP,
  tw_close TIMESTAMP
);

INSERT INTO vroom.shipments_time_windows
(id, kind, tw_open, tw_close)
VALUES
(1, 'p', '2021-09-02 09:27:05', '2021-09-02 10:00:50'),
(1, 'd', '2021-09-02 15:55:25', '2021-09-02 16:25:00'),
(2, 'p', '2021-09-02 09:06:15', '2021-09-02 09:27:55'),
(2, 'd', '2021-09-02 10:10:50', '2021-09-02 10:33:45'),
(3, 'p', '2021-09-02 13:18:45', '2021-09-02 13:52:30'),
(3, 'd', '2021-09-02 14:43:45', '2021-09-02 15:02:30'),
(4, 'p', '2021-09-02 10:46:15', '2021-09-02 11:15:00'),
(4, 'd', '2021-09-02 11:28:45', '2021-09-02 11:50:50'),
(5, 'p', '2021-09-02 12:42:30', '2021-09-02 13:12:05'),
(5, 'd', '2021-09-02 14:02:55', '2021-09-02 14:25:50');
-- vroom SHIPMENTS TIME WINDOWS TABLE end


-- vroom VEHICLES TABLE start
CREATE TABLE vroom.vehicles (
  id BIGSERIAL PRIMARY KEY,
  start_id BIGINT,
  end_id BIGINT,
  capacity BIGINT[]    DEFAULT '{200}',
  skills INTEGER[]     DEFAULT '{0}',
  tw_open TIMESTAMP,
  tw_close TIMESTAMP   DEFAULT '2021-09-02 17:35:00',
  speed_factor FLOAT   DEFAULT 1.0,
  max_tasks INTEGER    DEFAULT 20
);

INSERT INTO vroom.vehicles (start_id, end_id, tw_open)
VALUES
(1, 1, '2021-09-02 09:00:00'),
(1, 3, '2021-09-02 09:01:40'),
(1, 1, '2021-09-02 09:00:00'),
(3, 3, '2021-09-02 09:00:00');
-- vroom VEHICLES TABLE end


-- vroom BREAKS TABLE start
CREATE TABLE vroom.breaks (
  id BIGSERIAL PRIMARY KEY,
  vehicle_id BIGINT REFERENCES vroom.vehicles(id),
  service INTERVAL
);

INSERT INTO vroom.breaks
(vehicle_id, service)
VALUES
(1, '00:00:00'),
(2, '00:00:10'),
(3, '00:00:00'),
(4, '00:00:00');
-- vroom BREAKS TABLE end


-- vroom BREAKS TIME WINDOWS TABLE start
CREATE TABLE vroom.breaks_time_windows (
  id BIGINT REFERENCES vroom.breaks(id),
  tw_open TIMESTAMP,
  tw_close TIMESTAMP
);

INSERT INTO vroom.breaks_time_windows (id, tw_open, tw_close)
  VALUES
(1, '2021-09-02 09:04:10', '2021-09-02 09:05:00'),
(2, '2021-09-02 09:04:10', '2021-09-02 09:04:35'),
(3, '2021-09-02 09:00:00', '2021-09-02 09:00:00'),
(4, '2021-09-02 09:04:10', '2021-09-02 09:04:10');
-- vroom BREAKS TIME WINDOWS TABLE end


-- vroom MATRIX TABLE start
CREATE TABLE vroom.matrix (
  start_id BIGINT,
  end_id BIGINT,
  duration INTERVAL,
  cost INTEGER GENERATED ALWAYS AS (EXTRACT(epoch FROM '00:01:30'::INTERVAL)::INTEGER) STORED
);

INSERT INTO vroom.matrix
(start_id, end_id, duration)
VALUES
(1, 1, '00:00:00'), (1, 2, '00:00:50'), (1, 3, '00:01:30'),
(1, 4, '00:01:15'), (1, 5, '00:01:46'), (1, 6, '00:02:07'),
(2, 1, '00:00:50'), (2, 2, '00:00:00'), (2, 3, '00:02:05'),
(2, 4, '00:01:30'), (2, 5, '00:02:25'), (2, 6, '00:02:07'),
(3, 1, '00:01:30'), (3, 2, '00:02:05'), (3, 3, '00:00:00'),
(3, 4, '00:00:50'), (3, 5, '00:00:25'), (3, 6, '00:01:30'),
(4, 1, '00:01:15'), (4, 2, '00:01:30'), (4, 3, '00:00:50'),
(4, 4, '00:00:00'), (4, 5, '00:01:15'), (4, 6, '00:00:55'),
(5, 1, '00:01:46'), (5, 2, '00:02:25'), (5, 3, '00:00:25'),
(5, 4, '00:01:15'), (5, 5, '00:00:00'), (5, 6, '00:01:51'),
(6, 1, '00:02:07'), (6, 2, '00:02:07'), (6, 3, '00:01:30'),
(6, 4, '00:00:55'), (6, 5, '00:01:51'), (6, 6, '00:00:00');

-- vroom MATRIX TABLE end
