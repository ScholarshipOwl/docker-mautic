# docker-mautic

Mautic 4 dockerfile with xtail added and application code copied to /var/www/html.

## Development

Build locally:

```bash
docker build -t scholarshipowl/mautic:5.2.6 .
```

Run locally bash on the container:

```bash
docker run -it --entrypoint="" scholarshipowl/mautic:5.2.6 bash
```

## Publish

```bash
docker push scholarshipowl/mautic:5.2.6
```
