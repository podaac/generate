# Stage 0 - Create from Perl 5.34.1-slim-buster image and install dependencies
# FROM perl:5.34.1-slim-buster as stage0
FROM perl:5.34.1-slim-buster
RUN apt update && apt install -y csh


# # Stage 1 - Copy Generate code
# # FROM stage0 as stage1
# RUN /bin/mkdir /data
# COPY . /app

# # Stage 4 - Execute code
# # FROM stage3 as stage4
# LABEL version="0.1" \
#     description="Containerized Generate: Downloader"
# ENTRYPOINT [ "/bin/tcsh", "/app/shell/startup_generic_downloader.csh" ] 