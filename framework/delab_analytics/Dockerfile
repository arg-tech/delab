# r-ver base
ARG R_VERSION=4.4
FROM rocker/r-ver:${R_VERSION}

# info
LABEL project.title="Deliberation Laboratory (DeLab)"
LABEL project.link="https://delab.uni-goettingen.de"
LABEL source.docker="https://github.com/rstudio/plumber/blob/main/Dockerfile"

# install sys packages and python
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev \
  curl \
  wget \
  libsodium-dev \
  libxml2-dev \
  python3 python3-dev python3-pip python3-venv \
  && rm -rf /var/lib/apt/lists/*

# install R packages
RUN install2.r --error --skipinstalled --ncpus -1 \
  --repos https://ropensci.r-universe.dev --repos getOption \
  reticulate \
  remotes \
  dplyr \  
  tidyr \
  stringr \
  udpipe \
  plyr \ 
  foreach \
  cld2 \
  text \
  plumber \
  keras3 \
  lsa \
  httr2 \
  jsonlite \
  && rm -rf /tmp/downloaded_packages

# install Python packages in virtual environment
# ENV VIRTUAL_ENV=./opt/.venv
# RUN python3 -m venv ${VIRTUAL_ENV}
# ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

COPY ./requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt --break-system-packages

# set working directory
WORKDIR /delab/app

#install nltk stopwords
# RUN python3 -c "import nltk; nltk.download('punkt'); nltk.download('punkt_tab'); nltk.download('stopwords')"
RUN python3 -m nltk.downloader punkt 
RUN python3 -m nltk.downloader punkt_tab
RUN python3 -m nltk.downloader stopwords

# create directories
RUN mkdir -p data
#RUN mkdir -p models
RUN mkdir -p rscripts_api

# add functions
#COPY ./data/ data/
#COPY ./models/ models/ #for dev purposes, the models are mounted as volume
COPY ./rscripts_api/ rscripts_api/

# make port available
EXPOSE 8840

# run plumber file
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(rev(commandArgs())[1]); args <- list(host = '0.0.0.0', port = 8840); if (packageVersion('plumber') >= '1.0.0') { pr$setDocs(TRUE) } else { args$swagger <- TRUE }; do.call(pr$run, args)"]

CMD ["/delab/app/rscripts_api/delab_analytics.R"]
