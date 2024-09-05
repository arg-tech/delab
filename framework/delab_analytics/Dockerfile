# r-ver base
ARG R_VERSION=4.4
FROM rocker/r-ver:${R_VERSION}

# info
LABEL project.title="Deliberation Laboratory (DeLab)"
LABEL project.link="https://delab.uni-goettingen.de"
LABEL source.docker="https://github.com/rstudio/plumber/blob/main/Dockerfile"

# BEGIN rstudio/plumber layers

# `rm` call removes `apt` cache
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

# install Python
#RUN /rocker_scripts/install_python.sh
#RUN apt-get install python3 python3-dev python3-pip python3-venv

# `rm` call removes install2.r's cache
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
  && rm -rf /tmp/downloaded_packages

## Remove this comment to always bust the Docker cache at this step
## https://stackoverflow.com/a/55621942/591574
#ADD https://github.com/rstudio/plumber/commits/ _docker_cache

# install Python packages
#RUN Rscript -e "reticulate::py_install('nltk')"
#RUN Rscript -e "reticulate::py_install('torch')"
#RUN Rscript -e "reticulate::py_install('transformers')"
#RUN Rscript -e "reticulate::py_install('tensorflow')"
#RUN Rscript -e "reticulate::py_install('tf-keras')"

RUN pip3 install torch 
RUN pip3 install transformers
RUN pip3 install tensorflow
RUN pip3 install tf-keras
RUN pip3 install huggingface_hub
RUN pip3 install nltk

# set working directory
WORKDIR /delab/app

#install nltk stopwords
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
