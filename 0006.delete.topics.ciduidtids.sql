DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'cid:' || t."cid" || ':uid:' || COALESCE(t."uid", 0) || ':tids'
   AND uc."type" = 'zset'
   AND uc."unique_string" = t."tid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM t."timestamp") * 1000)::NUMERIC;
