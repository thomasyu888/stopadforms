FROM sagebionetworks/shiny-base:release-1.0
# This is the expected application installation folder
WORKDIR /srv/shiny-server/app
COPY --chown=shiny ./ ./
# renv restore
RUN Rscript -e "renv::restore()"
# Set up Python and install the Synapse Python client
RUN Rscript -e "library(reticulate); install_miniconda(); py_discover_config(); py_install(c('synapseclient','pandas'), pip = TRUE, pip_ignore_installed=TRUE)"
# The base image has a start up script "startup.sh".  We need an additional step before
# running that script, to pass a configuration env var to Shiny
CMD ["./stopadforms_startup.sh"]

# Gate the completion of 'docker build' on successfully running the tests
# The following is commented out because it results is multiple instances of the error:
# 'local_language' is not an exported object from 'namespace:withr'
#RUN Rscript -e "install.packages(c('rcmdcheck'), repos='http://cran.rstudio.com/')"
#RUN Rscript -e "rcmdcheck::rcmdcheck(args = '--no-manual', error_on = 'warning', check_dir = 'check')"