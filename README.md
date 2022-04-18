# generate

Generate is a program that downloads data from the Ocean Biology Processing Group (OBPG). Generate processes the data is downloads to create three Level 2P datasets.

Generate downloads the following data:
- MODIS Aqua: https://oceancolor.gsfc.nasa.gov/data/aqua/
- MODIS Terra: https://oceancolor.gsfc.nasa.gov/data/terra/
- VIIRS: https://oceancolor.gsfc.nasa.gov/data/viirs-snpp/

The API for searching and downloading data can be found here: https://oceancolor.gsfc.nasa.gov/data/download_methods/#api

Generate outputs the following data:
- MODIS_A-JPL-L2P-v2019.0: https://podaac.jpl.nasa.gov/dataset/MODIS_A-JPL-L2P-v2019.0
- MODIS_T-JPL-L2P-v2019.0: https://podaac.jpl.nasa.gov/dataset/MODIS_T-JPL-L2P-v2019.0
- VIIRS_NPP-JPL-L2P-v2016.2: https://podaac.jpl.nasa.gov/dataset/VIIRS_NPP-JPL-L2P-v2016.2

## components

Generate consists of several components:
- download list creator: Creates list of files to download (search and download from OBPG).
- downloader: Downloads files from lists created by the download list creator.