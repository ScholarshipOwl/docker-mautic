# Rebuild PHP 7.4.33 inside Mautic 4 with the official source backport for
# CVE-2026-109618 and CVE-2026-109619. Mautic itself stays on v4.
# php -v remains 7.4.33; the patch does not change the version string.
# The backport turns PHP session upload progress off.

FROM mautic/mautic:v4 AS php-build

ARG PHP_FIX_COMMIT=712e60f9edfd03f0960fc4fc3c2c375f42b90aa2

RUN set -eux; \
    { \
        echo 'deb http://archive.debian.org/debian bullseye main'; \
        echo 'deb http://archive.debian.org/debian bullseye-updates main'; \
        echo 'deb http://archive.debian.org/debian-security bullseye-security main'; \
    } > /etc/apt/sources.list; \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS git patch \
        libargon2-dev libcurl4-openssl-dev libonig-dev libreadline-dev libsodium-dev \
        libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev \
    ; \
    case "$(php-config --configure-options)" in \
        *--with-apxs2*) apt-get install -y --no-install-recommends apache2-dev ;; \
    esac; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    git init -q /usr/src/php-fix; \
    cd /usr/src/php-fix; \
    git remote add origin https://github.com/php/php-src.git; \
    git fetch -q --depth 2 --filter=blob:none origin "$PHP_FIX_COMMIT"; \
    git diff "$PHP_FIX_COMMIT^" "$PHP_FIX_COMMIT" > /usr/src/php-fix.patch

RUN set -eux; \
    export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"; \
    configureOptions="$(php-config --configure-options)"; \
    if [ ! -f /usr/src/php.tar.xz ]; then \
        curl -fsSL -o /usr/src/php.tar.xz https://www.php.net/distributions/php-7.4.33.tar.xz; \
        echo '924846abf93bc613815c55dd3f5809377813ac62a9ec4eb3778675b82a27b927  /usr/src/php.tar.xz' | sha256sum -c -; \
    fi; \
    docker-php-source extract; \
    cd /usr/src/php; \
    patch -p1 --forward --no-backup-if-mismatch < /usr/src/php-fix.patch; \
    mkdir -p /out/usr/src; \
    tar -cJf /out/usr/src/php.tar.xz -C /usr/src --exclude=.docker-delete-me \
        --transform 's,^php,php-7.4.33,' php; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    [ -e /usr/include/curl ] || [ -e /usr/local/include/curl ] \
        || ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
    ./configure $configureOptions; \
    make -j "$(nproc)"; \
    mkdir -p /out/etc/apache2/mods-available; \
    make INSTALL_ROOT=/out install-sapi install-binaries install-build \
        install-headers install-programs install-modules; \
    rm -rf /out/etc; \
    find /out -type f -perm '/0111' -exec strip --strip-all '{}' + || :

FROM mautic/mautic:v4

COPY --from=php-build /out/ /

RUN set -eux; \
    { \
        echo 'deb http://archive.debian.org/debian bullseye main'; \
        echo 'deb http://archive.debian.org/debian bullseye-updates main'; \
        echo 'deb http://archive.debian.org/debian-security bullseye-security main'; \
    } > /etc/apt/sources.list; \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until; \
    apt-get update; \
    apt-get install -y xtail; \
    rm -rf /var/lib/apt/lists/*; \
    pecl install --force redis; \
    rm -rf /tmp/pear; \
    docker-php-ext-enable redis; \
    php -v; \
    php -m

# Copy application files into the web root.
RUN tar cf - --one-file-system --exclude="./media" --exclude="./var/spool" --exclude="./var/tmp/imports" -C /usr/src/mautic . | tar xf -

CMD ["apache2-foreground"]
