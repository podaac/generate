# Stage 0 - Create from Perl 5.34.1-slim-buster image and install dependencies
# FROM perl:5.34.1-slim-buster as stage0
FROM perl:5.34.1-slim-buster
RUN apt update && apt install -y tcsh libfreetype6 libxpm4 libxmu6 libidn11
RUN ln -s /usr/lib/x86_64-linux-gnu/libXpm.so.4.11.0 /usr/lib/x86_64-linux-gnu/libXp.so.6

# Stage 1 - Copy Generate code
# FROM stage0 as stage1
RUN /bin/mkdir /data
COPY . /app

# Stage 2 - Execute code
# FROM stage1 as stage2
LABEL version="0.1" \
    description="Containerized Generate: Download Task Tracker"
ENTRYPOINT [ "/bin/tcsh", "/app/shell/startup_modis_level2_tasks_tracker.csh" ]