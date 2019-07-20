DELETE FROM "classify"."unclassified" uc
 USING "classify"."flags" f
 WHERE uc."_key" = 'flag:' || f."flagId"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'assignee'
   AND uc."value_string" = COALESCE(f."assignee"::TEXT, '');