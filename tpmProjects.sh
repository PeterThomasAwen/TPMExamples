##Params
BASEURL='https://tpm.mydomain.com/index.php/'
REQUESTURI='api/v5/projects.json'
PUBKEY='YOUR PUBLIC KEY'
PRIVKEY='YOUR PRIVATE KEY'

PROJECTNAME='name'
parent_id=0

#RequestBody
json=$(jq -n \
          --arg name "$PROJECTNAME" \
          --argjson parent_id "$parent_id"  \
          '{name:$name,parent_id:$parent_id}')
#Remove spaces to match php output
request_body=$(echo "$json" | tr -d ' \n\t')

echo $request_body

#HMAC ($hash)
timestamp=$(date +%s)
unhashed="${REQUESTURI}${timestamp}${request_body}"
hash=$(echo -n "$unhashed" | openssl dgst -sha256 -hmac "$PRIVKEY" | sed 's/^.* //')

# Define request headers
headers=(
  -H "X-Public-Key: $PUBKEY"
  -H "X-Request-Hash: $hash"
  -H "X-Request-Timestamp: $timestamp"
  -H "Content-Type: application/json; charset=utf-8"
)

URL="$BASEURL$REQUESTURI"

response=$(curl "${headers[@]}" -X POST -d "$request_body" "$URL")

echo "Response: $response"
