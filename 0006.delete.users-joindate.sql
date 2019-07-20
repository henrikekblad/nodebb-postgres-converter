DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'users:joindate'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."uid"::TEXT;
-- allow any value