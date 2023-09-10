CREATE TABLE insert_perf (
                             id INTEGER,
                             str VARCHAR(200),
                             num FLOAT
);
INSERT INTO insert_perf VALUES ( 1, 'hello', 3.14 );
INSERT INTO insert_perf VALUES ( 2, 'goodbye', 6.28 );

SHOW 'STORAGE' STATS;
EXIT;