# load existing image
FROM rocker/tidyverse:4.1.0

#install packages
RUN R -e "install.packages('basedosdados', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyverse', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggplot2', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggsci', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('sf', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('viridis', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('hrbrthemes', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('readxl', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('geobr')"
  
#copy needed files
COPY /input/municip_ma_amazlegal.csv /input/municip_ma_amazlegal.csv 
COPY /input/PRODES /input/PRODES  
COPY /input/RELATORIO_DTB_BRASIL_MUNICIPIO.xls /input/RELATORIO_DTB_BRASIL_MUNICIPIO.xls  
COPY /output/data/Estados_t /output/data/Estados_t
COPY /code/code_1.r /code/code_1.r  

#run R script
CMD Rscript /code/code_1.r