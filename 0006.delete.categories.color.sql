DELETE FROM "classify"."unclassified" uc
 USING "classify"."categories" c
 WHERE uc."_key" = 'category:' || c."cid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'color'
   AND uc."value_string" = COALESCE(c."color", '');