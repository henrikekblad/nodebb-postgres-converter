DELETE FROM "classify"."unclassified" uc
 USING "classify"."flags" f
 WHERE uc."_key" = 'flag:' || f."flagId"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'targetId'
   AND uc."value_string" = COALESCE(f."targetPid", f."targetUid")::TEXT;
