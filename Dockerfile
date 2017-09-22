FROM centos:7

RUN yum -y update && yum -y install \
	cyrus-sasl-devel \
	epel-release \
	java-1.8.0-openjdk \
	java-1.8.0-openjdk-devel \
	libapreq2-devel \
	libcurl-devel \
	libpng-devel \
	libtiff-devel \
	libjpeg-turbo-devel \
	openssl-devel \
	wget \
	yum-utils && \
	yum clean all

RUN yum -y update && yum -y install \
	R

RUN	R -e "install.packages('shiny', repos='http://cran.rstudio.com/')" && \
	wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.5.3.838-rh5-x86_64.rpm && \
	yum -y install --nogpgcheck shiny-server-1.5.3.838-rh5-x86_64.rpm && \
	R -e "install.packages(c('dplyr', 'flexdashboard', 'ggmap', 'ggvis', 'lubridate', 'magrittr', 'mongolite', 'readr', 'shinydashboard', 'shinyjs'), repos='https://cran.rstudio.com/')"
	
COPY ./app /srv/shiny-server/iot
COPY ./shiny-server.conf /etc/shiny-server/shiny-server.conf

EXPOSE 3838

CMD [ "shiny-server" ]
