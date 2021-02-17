DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id int primary key,
    status text,
    total real,
    created_at text
);
INSERT INTO orders
values (1, 'completed', 100, '2021-02-01 00:00:00'),
       (2, 'completed', 140, '2021-02-02 00:00:00'),
       (3, 'processing', 130, '2021-02-05 00:00:00'),
       (4, 'processing', 135, '2021-02-06 00:00:00'),
       (5, 'pending', 120, '2021-02-08 00:00:00'),
       (6, 'pending', 130, '2021-02-08 12:00:00');