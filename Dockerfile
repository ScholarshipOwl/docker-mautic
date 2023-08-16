FROM mautic/mautic:v4

#install xtail
RUN apt-get update -y && \
    apt-get install xtail && \
    apt-get clean

CMD ["apache2-foreground"]
