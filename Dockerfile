FROM fedora

# Odoo version
#
ENV ODOO_VERSION 11.0

# Odoo requires a non-standard build of wkhtmltopdf for many use cases
# (including running without a local X display).
#
ENV H2P_BASE https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download
ENV H2P_VER 0.12.5
ENV H2P_REL 1
ENV H2P_FILE wkhtmltox-${H2P_VER}-${H2P_REL}.centos7.x86_64.rpm
ENV H2P_URI ${H2P_BASE}/${H2P_VER}/${H2P_FILE}

# Packages
#
USER root
RUN dnf update -y ; dnf clean all
RUN dnf install -y python3-PyPDF2 python3-passlib python3-babel \
		   python3-werkzeug python3-lxml python3-decorator \
		   python3-dateutil python3-yaml python3-psycopg2 \
		   python3-pillow python3-psutil python3-requests \
		   python3-jinja2 python3-reportlab python3-html2text \
		   python3-docutils python3-num2words python3-phonenumbers \
		   python3-coverage python3-coveralls python3-magic \
		   wkhtmltopdf nodejs-less postgresql-server \
		   findutils unzip libpng15 compat-openssl10 ${H2P_URI} ; \
    dnf clean all

# PostgreSQL initialisation
#
ENV PGDATA /var/lib/pgsql/data
USER postgres
RUN initdb --auth trust --encoding utf8

# Odoo user and database
#
USER root
RUN useradd odoo
USER postgres
RUN pg_ctl start ; \
    createuser odoo ; \
    createdb --owner odoo odoo ; \
    pg_ctl stop

# Odoo wrapper script
#
USER root
RUN mkdir /opt/odoo-addons
COPY odoo-wrapper /usr/local/bin/odoo-wrapper

# Upstream Odoo snapshot
#
ADD https://codeload.github.com/odoo/odoo/zip/${ODOO_VERSION} /opt/odoo.zip
USER root
RUN unzip -q -d /opt /opt/odoo.zip ; \
    ln -s odoo-${ODOO_VERSION} /opt/odoo

# Create base Odoo database
#
USER root
RUN odoo-wrapper --without-demo=all

# Entry point
#
ENTRYPOINT ["/usr/local/bin/odoo-wrapper"]
