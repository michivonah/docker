docker run \
  -d \
  --name baserow \
  -e BASEROW_PUBLIC_URL=http://localhost:4444 \
  -v baserow_data:/baserow/data \
  -p 4444:80 \
  --restart unless-stopped \
  baserow/baserow:2.0.6