## Set up##
library(basedosdados)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(ggsci)
library(geobr)
library(sf)
library(viridis)
library(hrbrthemes)
## Variáveis Auxiliares ##
filtro = c( "Acre", "Amapá", "Amazonas", "Mato Grosso", "Pará", "Rondônia", "Roraima", "Tocantins", "Maranhão")
filtro2 = c( "Acre", "Amapá", "Amazônas", "Mato Grosso", "Pará", "Rondônia", "Roraima", "Tocantins", "Maranhão")
filtro_3 = read.csv(file = "C:\\Users\\caiog\\Projeto_Final_Dados\\input\\municip_ma_amazlegal.csv")
filtro_3 = rbind(filtro_3, 1100015)
UF = c("AC", "AP", "AM", "MA", "MT", "PA", "RO", "RR", "TO","AC", "AP", "AM", "MA", "MT", "PA", "RO", "RR", "TO")
# Inputs 1 - Base Prodes
set_billing_id("cienciadadosverao")
query <- bdplyr("br_inpe_prodes.desmatamento_municipio")
Prodes <- bd_collect(query)
save(Prodes, file="C:\\Users\\caiog\\Projeto_Final_Dados\\input\\PRODES")
# Input 2 Base IBGE - ID Municipios a 7 dígitos
cod_municip = read_excel("C:\\Users\\caiog\\Projeto_Final_Dados\\input\\RELATORIO_DTB_BRASIL_MUNICIPIO.xls")
cod_municip %>%
     rename(id_municipio = "Código Município Completo")
# Input 3 geobr_ shapefile
geobr = read_municipality(code_muni="all", year=2020)
subset(geobr, code_muni %in% filtro_3$X1100015)
geobr %>%
     rename(id_municipio = "code_muni")
save(geobr, file="C:\\Users\\caiog\\Projeto_Final_Dados\\input\\geobr")
# Adicionar Variáveis úteis de análise a partir dados primários
Prodes = Prodes %>%
  mutate(adesmatprop=desmatado/area)
Prodes = Prodes%>% 
  left_join(cod_municip, Prodes, by = "id_municipio")
### Criar um dataframe que consolide Estados
Estados = Prodes %>%
  group_by(ano, Nome_UF) %>%
  summarize(desmat_est = sum(desmatado))
Estados_2 = Prodes %>%
  group_by(ano, Nome_UF) %>%
  summarize(area_est = sum(area))
Estados = left_join(Estados, Estados_2)
Estados = Estados %>%
  mutate(area_desmat_prop = 100*desmat_est/area_est)
rm(Estados_2)
### Criar um dataframe que consolide Amazônia Legal
Amazon_Legal = Prodes %>%
  group_by(ano) %>%
  summarize(area = sum(area), desmatado = sum(desmatado), incremento = sum(incremento), floresta = sum(floresta), nuvem = sum(nuvem), nao_observado = sum(nao_observado),
  nao_floresta = sum(nao_floresta), hidrografia = sum(hidrografia))
Amazon_Legal = Amazon_Legal %>%
     mutate(area_desmat_prop = 100* desmatado/area, floresta_desmat_prop = 100* floresta/area, nuvem_prop = 100* nuvem/area, nobs_prop = 100* nao_observado/area, 
     nfloresta_prop = 100* nao_floresta/area)
Amazon_Legal$ano = Amazon_Legal$ano = as.character(as.numeric(Amazon_Legal$ano))
## Usando geobr para criar mapas ##
Prodes_2005 = Prodes %>%
  filter(ano==2005) %>%
  Prodes_2005$id_municipio = as.numeric(as.character(Prodes_2005$id_municipio))
Prodes_2010 = Prodes %>%
  filter(ano==2010)
  Prodes_2010$id_municipio = as.numeric(as.character(Prodes_2010$id_municipio))
Prodes_2015 = Prodes %>%
  filter(ano==2015)
  Prodes_2015$id_municipio = as.numeric(as.character(Prodes_2015$id_municipio))
Prodes_2020 = Prodes %>%
  filter(ano==2020)
  Prodes_2020$id_municipio = as.numeric(as.character(Prodes_2020$id_municipio))
geobr2005 = left_join(geobr, Prodes_2005, by = "id_municipio")
geobr2010 = left_join(geobr, Prodes_2010, by = "id_municipio")
geobr2015 = left_join(geobr, Prodes_2015, by = "id_municipio")
geobr2020 = left_join(geobr, Prodes_2020, by = "id_municipio")
## Dataframe para Gráfico 2
Estados_t = Estados %>%
  filter(ano %in% c(2005, 2020))
Estados_t$ano = as.character(as.numeric(Estados_t$ano))
Estados_t$UF = UF
## Dataframe para Graf3
geobr_municip = geobr2020 %>%
     select(id_municipio, name_muni, name_state,adesmatprop)
geobr_municip = geobr_municip %>%
     rename(adesmatprop_20 = "adesmatprop")
geobr_municip_2005 = geobr2005 %>%
     select(id_municipio, name_muni, name_state,adesmatprop)
geobr_municip_2005 = geobr_municip_2005 %>%
     rename(adesmatprop_05 = "adesmatprop")
adesmatprop_05 = geobr_municip_2005 %>%
     pull(adesmatprop_05)
geobr_municip$adesmatprop_05 = adesmatprop_05
rm(geobr_municip_2005, adesmatprop_05)
geobr_municip = geobr_municip %>%
     mutate(incremento = adesmatprop_20 - adesmatprop_05)
geobr_municip_2 = geobr_municip %>% arrange(desc(incremento))
geobr_municip_2 = geobr_municip_2 %>%
     mutate(indice = ifelse(incremento > 0.10284281, 1, 0))
# Salvando outputs
save(Amazon_Legal, file="C:\\Users\\caiog\\Projeto_Final_Dados\\output\\data\\Amazon_Legal")
save(Estados, file="C:\\Users\\caiog\\Projeto_Final_Dados\\output\\data\\Estados")
save(Estados_t, file="C:\\Users\\caiog\\Projeto_Final_Dados\\output\\data\\Estados_t")
save(Prodes, file="C:\\Users\\caiog\\Projeto_Final_Dados\\output\\data\\Prodes_f" )
# Mapas anos
png("output/figures/gra_2005.png")
     ggplot(geobr2005) +
    geom_sf(aes(fill=adesmatprop)) +
    scale_fill_distiller(palette = "Spectral")
dev.off()
png("output/figures/gra_2010.png")
     ggplot(geobr2010) +
    geom_sf(aes(fill=adesmatprop)) +
    scale_fill_distiller(palette = "Spectral")
dev.off()
png("output/figures/gra_2015.png")
     ggplot(geobr2015) +
    geom_sf(aes(fill=adesmatprop)) +
    scale_fill_distiller(palette = "Spectral")
dev.off()
png("output/figures/gra_2020.png")
     ggplot(geobr2020) +
    geom_sf(aes(fill=adesmatprop)) +
    scale_fill_distiller(palette = "Spectral")
dev.off()
## Mapa 30 piores municípios
png("output/figures/graf_30mais.png")
ggplot(geobr_municip_2) +
     geom_sf(aes(fill=indice)) +
     scale_fill_distiller(palette = "Spectral") +
     guides(fill="none") +
     ggtitle("Maior Incremento em Área Desmatada entre 2005 e 2020 (30 Municip.)")
dev.off()
## Gráfico 1 - Am Legal (2005-2010) incremento ao ano
png("output/figures/graf_1.png")
ggplot(subset(Amazon_Legal,ano>2005), aes(x=ano, y=incremento)) +
  geom_line(size=1.5, color="darkblue") +
  scale_fill_d3() +
  ggtitle("Incremento Área Desmatada") +
  theme_classic()+
  theme(text = element_text(size = 15)) +     
  xlab("Ano") +
  ylab("Incremento área desmatada (km2)") +
  theme(plot.title=element_text(hjust=0.5))
dev.off()
## Gráfico 2 - Estados (2005 - 2010) % área desmatada
png("output/figures/graf_2.png")
ggplot(Estados_t, aes(x=UF, y=area_desmat_prop, fill=ano)) + 
  geom_bar(position="dodge", stat="identity") +
  scale_fill_d3() +
  ggtitle("Área Desmatada (% total)") +
  theme_ipsum()+
  xlab("Estados")+
  ylab("% de área desmatada") +
  theme(plot.title=element_text(hjust=0.5))
dev.off()


