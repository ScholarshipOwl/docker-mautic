# docker-mautic

Mautic 5.2.11 image with the Sparkpost plugin. The base image already contains PHP 8.2.35.

## Development

Build locally:

```bash
docker build -t scholarshipowl/mautic:5.2.11 .
```

Run locally bash on the container:

```bash
docker run -it --entrypoint="" scholarshipowl/mautic:5.2.11 bash
```

## Publish

```bash
docker push scholarshipowl/mautic:5.2.11
```
