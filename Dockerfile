FROM mautic/mautic:v4

#install xtail
RUN apt-get update -y && \
    apt-get install xtail && \
    apt-get clean

#copy application files
RUN tar cf - --one-file-system --exclude="./media" --exclude="./var/spool" --exclude="./var/tmp/imports" -C /usr/src/mautic . | tar xf -

CMD ["apache2-foreground"]
