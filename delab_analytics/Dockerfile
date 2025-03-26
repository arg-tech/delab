# r-ver base
ARG R_VERSION=4.4
FROM rocker/r-ver:${R_VERSION}

# info
LABEL project.title="Deliberation Laboratory (DeLab)"
# LABEL project.link="https://delab.uni-goettingen.de"
LABEL source.docker="https://github.com/rstudio/plumber/blob/main/Dockerfile"

# install sys packages and python
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  git-core \
  git-lfs \
  unzip \
  libssl-dev \
  libcurl4-gnutls-dev \
  curl \
  wget \
  libsodium-dev \
  libxml2-dev \
  # default-jdk \
  python3 python3-dev python3-pip python3-venv \
  && rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt .
RUN pip3 install -r requirements.txt --break-system-packages

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

RUN echo 'library(reticulate)\nuse_python("/usr/bin/python3", required = TRUE)' > ~/.Rprofile

# set working directory
WORKDIR /delab/app

#install nltk stopwords
RUN python3 -m nltk.downloader punkt 
RUN python3 -m nltk.downloader punkt_tab
RUN python3 -m nltk.downloader stopwords
RUN python3 -m spacy download en_core_web_sm --break-system-packages

WORKDIR /delab/app/models
RUN mkdir -p udpipe
COPY ./connectives_discourse_markers_PDTB.txt ./

RUN wget "https://github.com/jwijffels/udpipe.models.ud.2.5/raw/master/inst/udpipe-ud-2.5-191206/english-ewt-ud-2.5-191206.udpipe" -P udpipe
RUN wget "https://github.com/jwijffels/udpipe.models.ud.2.5/raw/master/inst/udpipe-ud-2.5-191206/german-gsd-ud-2.5-191206.udpipe" -P udpipe

WORKDIR /delab/app

RUN wget -O models.zip "https://owncloud.gwdg.de/index.php/s/Y6sWdZv7G9jd117/download"
RUN unzip models.zip
RUN rm models.zip

ENV HF_HUB_ENABLE_HF_TRANSFER=1

RUN huggingface-cli download cardiffnlp/twitter-xlm-roberta-base --local-dir models/twitter-xlm-roberta-base
RUN huggingface-cli download cardiffnlp/twitter-roberta-base-sentiment-latest --local-dir models/twitter-roberta-base-sentiment-latest
RUN huggingface-cli download raruidol/ArgumentMining-EN-ARI-AIF-RoBERTa_L --local-dir models/ArgumentMining-EN-ARI-AIF-RoBERTa_L
RUN huggingface-cli download oenni11/self-contradiction --local-dir models/self-contradiction

RUN mkdir -p rscripts_api
COPY ./rscripts_api/ rscripts_api/

EXPOSE 8840

# run plumber file
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(rev(commandArgs())[1]); args <- list(host = '0.0.0.0', port = 8840); if (packageVersion('plumber') >= '1.0.0') { pr$setDocs(TRUE) } else { args$swagger <- TRUE }; do.call(pr$run, args)"]

CMD ["/delab/app/rscripts_api/delab_analytics.R"]
