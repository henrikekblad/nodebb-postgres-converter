CREATE TABLE "classify"."categories" (
	-- structure
	"cid" BIGSERIAL PRIMARY KEY,
	"slug" TEXT COLLATE "C" NOT NULL CHECK("slug" LIKE "cid" || '/%'),
	"parentCid" BIGINT,
	"order" INT NOT NULL GENERATED BY DEFAULT AS IDENTITY,

	-- metadata
	"name" TEXT COLLATE "C" NOT NULL,
	"description" TEXT COLLATE "C" NOT NULL DEFAULT '',
	"descriptionParsed" TEXT COLLATE "C",
	"link" TEXT COLLATE "C",
	"disabled" BOOLEAN NOT NULL DEFAULT FALSE,
	"numRecentReplies" INT NOT NULL DEFAULT 1,

	-- style
	"color" TEXT COLLATE "C",
	"bgColor" TEXT COLLATE "C",
	"class" TEXT COLLATE "C",
	"icon" TEXT COLLATE "C",
	"image" TEXT COLLATE "C",
	"imageClass" TEXT COLLATE "C",

	-- counters
	"post_count" BIGINT NOT NULL DEFAULT 0,
	"topic_count" BIGINT NOT NULL DEFAULT 0,
	"timesClicked" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

CREATE INDEX ON "classify"."categories"("parentCid" NULLS FIRST, "order");
CREATE INDEX ON "classify"."categories"("disabled");

ALTER TABLE "classify"."categories" CLUSTER ON "categories_pkey";

WITH cids AS (
	SELECT "unique_string"::BIGINT "cid",
	       'category:' || "unique_string" "key"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'categories:cid'
	   AND "type" = 'zset'
)
INSERT INTO "classify"."categories"
SELECT cid,
       "classify"."get_hash_string"("key", 'slug'),
       "classify"."get_hash_int"("key", 'parentCid'),
       COALESCE("classify"."get_hash_int"("key", 'order'), 0),
       "classify"."get_hash_string"("key", 'name'),
       COALESCE("classify"."get_hash_string"("key", 'description'), ''),
       "classify"."get_hash_string"("key", 'descriptionParsed'),
       "classify"."get_hash_string"("key", 'link'),
       COALESCE("classify"."get_hash_boolean"("key", 'disabled'), FALSE),
       COALESCE("classify"."get_hash_string"("key", 'numRecentReplies'), '1')::INT,
       "classify"."get_hash_string"("key", 'color'),
       "classify"."get_hash_string"("key", 'bgColor'),
       "classify"."get_hash_string"("key", 'class'),
       "classify"."get_hash_string"("key", 'icon'),
       "classify"."get_hash_string"("key", 'image'),
       "classify"."get_hash_string"("key", 'imageClass'),
       COALESCE("classify"."get_hash_int"("key", 'post_count'), 0),
       COALESCE("classify"."get_hash_int"("key", 'topic_count'), 0),
       COALESCE("classify"."get_hash_int"("key", 'timesClicked'), 0)
  FROM cids;

\o /dev/null
SELECT setval('classify.categories_cid_seq', "classify"."get_hash_string"('global', 'nextCid')::BIGINT);
\o