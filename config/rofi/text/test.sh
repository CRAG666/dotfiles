
url_regex='^(https?|ftp|file)://[\p{L}\p{N}\-._~:/?#\[\]@!$&'"'"'()*+,;=%]+$'

url="https://マリウス.com/"

if echo "$url" | grep -Pq "$url_regex"; then
    echo "URL válida"
else
    echo "URL inválida"
fi
