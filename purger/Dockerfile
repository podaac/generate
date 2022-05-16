# Stage 0 - Create from Perl 5.34.1-slim-buster image and install dependencies
# FROM perl:5.34.1-slim-buster as stage0
FROM perl:5.34.1-slim-buster
RUN apt update \
    && apt install -y tcsh 

# Stage 2 - Copy Generate code
# FROM stage0 as stage1
RUN /bin/mkdir /data
COPY . /app

# Stage 3 - Execute code
# FROM stage1 as stage2
LABEL version="0.1" \
    description="Containerized Generate: Purger"
ENTRYPOINT [ "/bin/tcsh", "/app/shell/startup_level2_purgers.csh" ]