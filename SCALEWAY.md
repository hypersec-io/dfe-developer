curl -X POST \
  -H "X-Auth-Token: $SCW_SECRET_KEY" \
  -H "Content-Type: application/json" \
  "https://api.scaleway.com/apple-silicon/v1alpha1/zones/$ZONE/servers" \
  -d '{
     "name":"My_Mac_Mini",
     "project_id":"<YOUR_PROJECT_ID>",
     "type":"M1-M"
   }'
``` :contentReference[oaicite:6]{index=6}  
