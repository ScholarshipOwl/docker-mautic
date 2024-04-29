# docker-mautic

Mautic 4 dockerfile with xtail added and application code copied to /var/www/html.

## Development

Build locally:

```bash
docker build -t scholarshipowl/mautic:v4.1.1 .
```

Run locally bash on the container:

```bash
docker run -it --entrypoint="" scholarshipowl/mautic:v4.1.1 bash
```

## Publish

```bash
docker push scholarshipowl/mautic:v4.1.1
```
