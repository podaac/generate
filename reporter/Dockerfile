# Stage 0 - Create from Perl 5.34.1-slim-buster image and install dependencies
# FROM perl:5.34.1-slim-buster as stage0
FROM perl:5.34.1-slim-buster
RUN apt update \
    && apt install -y tcsh 

# Stage 1 - postfix/mailutils setup
# FROM stage0 as stage1
RUN echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections \
    && echo "postfix postfix/mailname string reporter.generate" | debconf-set-selections \
    && echo "postfix postfix/mailname string reporter.generate.com" | debconf-set-selections \
    && apt install -y postfix \
    && /usr/sbin/postconf -e "inet_interfaces = loopback-only" \
    && /usr/sbin/postconf -e "local_transport = error:local delivery is disabled" \
    && apt install -y mailutils

# Stage 2 - Copy Generate code
# FROM stage1 as stage2
RUN /bin/mkdir /data
COPY . /app

# Stage 3 - Execute code
# FROM stage2 as stage3
LABEL version="0.1" \
    description="Containerized Generate: Reporter"
ENTRYPOINT [ "/bin/tcsh", "/app/print_generic_daily_report.csh" ]