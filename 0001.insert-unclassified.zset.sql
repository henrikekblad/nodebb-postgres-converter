INSERT INTO "classify"."unclassified" ("_key", "type", "unique_string", "value_numeric")
SELECT z."_key", z."type", z."value", z."score"
  FROM "legacy_zset" z;

ANALYZE "classify"."unclassified_zset";
