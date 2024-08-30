#=============================================================================* 
#  * ANALYSIS - Quarterly EBB-Polis Data
#==============================================================================*
# Project: Essential Workers & Wage Inequality
# Author: Christoph Janietz (University of Groningen)
# Last update: 04-06-2024
#
# Purpose: Figure 1-3 of the manuscript.
#          S15 & S16 of the Supplementary material.
#
# ---------------------------------------------------------------------------- *
#  
#  INDEX: 
#  1. Data preparation
#  2. Wage trends before the Covid-19 pandemic
#  3. Impact of the Covid-19 pandemic on the wage gap
# ---------------------------------------------------------------------------- *

library(haven)
library(readxl)
library(ggplot2)
library(tidyverse)
library(stringr)
library(scales)
library(ggrepel)
library(ggpubr)

######################
# 1. Data preparation
######################

##### Color palette
kandinsky_mono <- c("#3b7c70", "#3b7c70","#3b7c70","#3b7c70","#3b7c70","#3b7c70",
                    "#3b7c70","#3b7c70")
kandinsky <- c("#3b7c70", "#ce9642")
kandinsky3 <- c("#3b7c70", "#ce9642", "#898e9f")

##### Prepare for Fig. 1

wgds_all <- read_dta("H:/Christoph/art3/02_posted/real_hwage_dist_sector.dta")

wgds_all$sector <- ordered(wgds_all$sector, levels = c(1, 2, 3), 
                         labels = c("Private", "Non-Profit", "Public"))
wgds_all$crucial <- ordered(wgds_all$crucial, levels = c(0, 1), 
                          labels = c("Other workers", "Essential workers"))

wgds_priv <-filter(wgds_all, sector=="Private")
wgds_nopriv <-filter(wgds_all, sector!="Private")
wgds_nopriv_nombp <-filter(wgds_all, sector!="Private" & isco1!=1 & isco2!=24)

wgds_all <- mutate(wgds_all, set="All sectors \n (100% of sample)")
wgds_priv <- mutate(wgds_priv, set="Private sector \n (66.00% of sample)")
wgds_nopriv <- mutate(wgds_nopriv, set="Public & non-profit sector \n (34.00% of sample)")
wgds_nopriv_nombp <- mutate(wgds_nopriv_nombp, set="Public & non-profit sector (without managers) \n (29.66% of sample)")

wgds <- bind_rows(wgds_all, wgds_priv, wgds_nopriv, wgds_nopriv_nombp)

##### Prepare for Fig. 2
# Load data
rif_decomp <- read_dta("C:/Users/chrai/OneDrive/Dokumente/PhD Amsterdam/art3/data/decomposition_rif_detailed.dta")

rif_decompA <- filter(rif_decomp, Component=="Essential workers" | Component=="Other workers")
rif_decompB <- filter(rif_decomp, Component=="Sex Composition" | Component=="Sector Composition")
rif_decompC <- filter(rif_decomp, Component=="Quantile difference")

rif_decompA$crucial <- ordered(rif_decompA$crucial, levels = c(0, 1), 
                               labels = c("Other workers", "Essential workers"))

##### Prepare for Fig. 3
# Load data
wgs_q <- read_dta("H:/Christoph/art3/02_posted/avg_wgs_quarterly.dta")

#Factors
wgs_q$PUB_YQ <- ordered(wgs_q$PUB_YQ, levels = c(228, 229, 230, 231, 232, 233, 
                                                 234, 235, 236, 237, 238, 239, 
                                                 240, 241, 242, 243, 244, 245,
                                                 246, 247, 248, 249, 250, 251),
                        labels = c("2017 \nQ1", "2017 \nQ2", "2017 \nQ3", "2017 \nQ4", 
                                   "2018 \nQ1", "2018 \nQ2", "2018 \nQ3", "2018 \nQ4", 
                                   "2019 \nQ1", "2019 \nQ2", "2019 \nQ3", "2019 \nQ4", 
                                   "2020 \nQ1", "2020 \nQ2", "2020 \nQ3", "2020 \nQ4", 
                                   "2021 \nQ1", "2021 \nQ2", "2021 \nQ3", "2021 \nQ4",
                                   "2022 \nQ1", "2022 \nQ2", "2022 \nQ3", "2022 \nQ4"))
wgs_q$crucial <- factor(wgs_q$crucial, levels = c(0, 1), 
                        labels = c("Other workers", "Essential workers"))

##### Prepare for S15
# Load data
occ_comp <- read_dta("H:/Christoph/art3/02_posted/emplchng_occ_detail.dta")

#Factors
occ_comp$ess <- ordered(occ_comp$ess, levels = c(0, 1), 
                          labels = c("Other occupations", "Essential occupations"))

##### Prepare for S16
# Load data
event_study <- read_dta("H:/Christoph/art3/02_posted/event_study.dta")


##############################################
# 2. Wage trends before the Covid-19 pandemic
##############################################

# Figure 1 - Wage distribution & Sector
ggplot(wgds, aes(x=real_hwage, after_stat(count), linetype=crucial, 
                 fill=crucial, weight=svyw)) +
  geom_density(alpha=0.6) +
  scale_x_continuous(breaks = seq(0,70,10), limits = c(0,65),
                     labels = label_number(accuracy = 0.01, suffix = "€")) +
  scale_y_continuous(breaks = seq(0,30000,10000), limits = c(0, 30000)) +
  facet_wrap(~set) +
  scale_fill_manual(values = kandinsky) +
  scale_linetype_manual(values = c(2, 1)) +
  labs(x = "Real hourly wage (2006-2019)",  y = "Frequency count", 
       caption = "Source: EBB & SPOLIS, 2006-2019",
       color = "", fill = "", linetype="") +
  theme_minimal() +
  theme(legend.position="bottom")

ggsave("FIG1_hwage_dist_sector.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)

# Figure 1 - Wage distribution & Sector (BW)
ggplot(wgds, aes(x=real_hwage, after_stat(count), linetype=crucial, 
                 fill=crucial, weight=svyw)) +
  geom_density(alpha=0.6) +
  scale_x_continuous(breaks = seq(0,70,10), limits = c(0,65),
                     labels = label_number(accuracy = 0.01, suffix = "€")) +
  scale_y_continuous(breaks = seq(0,30000,10000), limits = c(0, 30000)) +
  facet_wrap(~set) +
  scale_fill_grey() +
  scale_linetype_manual(values = c(2, 1)) +
  labs(x = "Real hourly wage (2006-2019)",  y = "Frequency count", 
       caption = "Source: EBB & SPOLIS, 2006-2019",
       color = "", fill = "", linetype="") +
  theme_minimal() +
  theme(legend.position="bottom")

ggsave("FIG1_hwage_dist_sector_BW.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)

# Figure 2 - RIF decomposition
a <- ggplot(rif_decompA, aes(y = value, x = Quantile, group=crucial, shape=crucial)) +
  geom_point(aes(colour = crucial), size = 2) +
  geom_line(aes(colour = crucial), linewidth = 0.5) +
  geom_ribbon(aes(ymin = lb, ymax = ub, fill = crucial),
              alpha=.5, linetype=0, size=2) +
  scale_x_continuous(breaks = seq(10,90,10), limits = c(10,90)) +  
  scale_fill_manual(values = kandinsky) +
  scale_colour_manual(values = kandinsky) +
  labs(x = "Quantile",  
       y = "Log real hourly wage", 
       caption = "Source: EBB + SPOLIS, 2006-2019", 
       colour = "", fill="", shape = "") +
  ggtitle("(A) Conditional quantile values") +
  theme_minimal() +
  theme(legend.position="bottom",
        plot.title = element_text(size=10))

b <- ggplot(rif_decompB, aes(y = value, x = Quantile, group=Component)) +
  geom_hline(yintercept=0, size=1, color = "grey") +
  geom_point(aes(colour = Component, shape= Component), size = 2) +
  geom_line(aes(colour = Component), linewidth = 0.5) +
  geom_ribbon(aes(ymin = lb, ymax = ub, fill = Component),
              alpha=.5, linetype=0, size=2) +
  geom_point(data=rif_decompC, aes(y = value, x = Quantile), size = 2, color="darkgrey", shape=1) +
  geom_line(data=rif_decompC, aes(y = value, x = Quantile), linewidth = 0.5, color="darkgrey", linetype="dashed") +
  scale_x_continuous(breaks = seq(10,90,10), limits = c(10,90)) + 
  scale_y_continuous(breaks = seq(-0.2,0.2,0.1), limits = c(-0.2,0.2)) +
  scale_fill_manual(values = kandinsky) +
  scale_colour_manual(values = kandinsky) +
  labs(x = "Quantile",  
       y = "", 
       caption = "Source: EBB + SPOLIS, 2006-2019", 
       colour = "", fill="", shape = "") +
  ggtitle("(B) Selected Decomposition components") +
  theme_minimal() +
  theme(legend.position="bottom",
        plot.title = element_text(size=10))

figure_rif_decomp <- ggarrange(a, b, ncol = 2, nrow = 1)
figure_rif_decomp

ggsave("FIG2_rif_decomp.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)

# Figure 2 - RIF decomposition (BW)
c <- ggplot(rif_decompA, aes(y = value, x = Quantile, group=crucial, shape=crucial)) +
  geom_point(aes(colour = crucial), size = 2) +
  geom_line(aes(colour = crucial), linewidth = 0.5) +
  geom_ribbon(aes(ymin = lb, ymax = ub, fill = crucial),
              alpha=.5, linetype=0, size=2) +
  scale_x_continuous(breaks = seq(10,90,10), limits = c(10,90)) +  
  scale_fill_grey() +
  scale_colour_grey() +
  labs(x = "Quantile",  
       y = "Log real hourly wage", 
       caption = "Source: EBB + SPOLIS, 2006-2019", 
       colour = "", fill="", shape = "") +
  ggtitle("(A) Conditional quantile values") +
  theme_minimal() +
  theme(legend.position="bottom",
        plot.title = element_text(size=10))

d <- ggplot(rif_decompB, aes(y = value, x = Quantile, group=Component)) +
  geom_hline(yintercept=0, size=1, color = "grey") +
  geom_point(aes(colour = Component, shape= Component), size = 2) +
  geom_line(aes(colour = Component), linewidth = 0.5) +
  geom_ribbon(aes(ymin = lb, ymax = ub, fill = Component),
              alpha=.5, linetype=0, size=2) +
  geom_point(data=rif_decompC, aes(y = value, x = Quantile), size = 2, color="darkgrey", shape=1) +
  geom_line(data=rif_decompC, aes(y = value, x = Quantile), linewidth = 0.5, color="darkgrey", linetype="dashed") +
  scale_x_continuous(breaks = seq(10,90,10), limits = c(10,90)) + 
  scale_y_continuous(breaks = seq(-0.2,0.2,0.1), limits = c(-0.2,0.2)) +
  scale_fill_grey() +
  scale_colour_grey() +
  labs(x = "Quantile",  
       y = "", 
       caption = "Source: EBB + SPOLIS, 2006-2019", 
       colour = "", fill="", shape = "") +
  ggtitle("(B) Selected Decomposition components") +
  theme_minimal() +
  theme(legend.position="bottom",
        plot.title = element_text(size=10))

figure_rif_decomp_BW <- ggarrange(c, d, ncol = 2, nrow = 1)
figure_rif_decomp_BW

ggsave("FIG2_rif_decomp_BW.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)

#######################################################
# 3. Impact of Covid-19 pandemic on wage differentials
#######################################################

# Figure 3 - Average hourly wage by quarter
ggplot(wgs_q, aes(y = avg_wage, x = PUB_YQ, group=crucial, shape=crucial)) +
  geom_vline(xintercept="2020 \nQ1", size=1, color = "grey") +
  geom_point(aes(colour = crucial), size = 2) +
  geom_line(aes(colour = crucial), linewidth = 0.5) +
  geom_ribbon(aes(ymin = ci_bottom, ymax = ci_top, fill = crucial),
              alpha=.5, linetype=0, size=2) +
  geom_text(aes(label = sprintf("%0.2f", round(after_stat(y), digits = 2))), 
            size = 3, vjust = -0.5, hjust = 0.75) +
  scale_y_continuous(breaks = seq(17,21,1), limits = c(16.5,21), 
                     labels = label_number(accuracy = 0.01, suffix = "€")) +  
  scale_fill_manual(values = kandinsky) +
  scale_colour_manual(values = kandinsky) +
  labs(x = "Year/quarter",  
       y = "Average real hourly wage", 
       caption = "Source: EBB + SPOLIS, 2017-2022", 
       colour = "", fill="", shape = "") +
  theme_minimal() +
  theme(legend.position="bottom")

ggsave("FIG3_avg_hwage_quarterly.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)

# Figure 3 - Average hourly wage by quarter (BW)
ggplot(wgs_q, aes(y = avg_wage, x = PUB_YQ, group=crucial, shape=crucial)) +
  geom_vline(xintercept="2020 \nQ1", size=1, color = "grey") +
  geom_point(aes(colour = crucial), size = 2) +
  geom_line(aes(colour = crucial), linewidth = 0.5) +
  geom_ribbon(aes(ymin = ci_bottom, ymax = ci_top, fill = crucial),
              alpha=.5, linetype=0, size=2) +
  geom_text(aes(label = sprintf("%0.2f", round(after_stat(y), digits = 2))), 
            size = 3, vjust = -0.5, hjust = 0.75) +
  scale_y_continuous(breaks = seq(17,21,1), limits = c(16.5,21), 
                     labels = label_number(accuracy = 0.01, suffix = "€")) +  
  scale_fill_grey() +
  scale_colour_grey() +
  labs(x = "Year/quarter",  
       y = "Average real hourly wage", 
       caption = "Source: EBB + SPOLIS, 2017-2022", 
       colour = "", fill="", shape = "") +
  theme_minimal() +
  theme(legend.position="bottom")

ggsave("FIG3_avg_hwage_quarterly_BW.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)


# S15 - Composition change by detailed occupations
ggplot(occ_comp, aes(y = empl_chng, x = r_hwage, colour = ess, size=p0, weight=p0)) +
  geom_hline(yintercept=0) +
  geom_point() +
  geom_smooth(method = "loess", formula = "y~x", se=FALSE, span=5) +
  guides(size = "none") +
  scale_y_continuous(breaks = seq(-1,1,0.25), limits = c(-1.03,1)) +
  scale_colour_manual(values = kandinsky) +
  labs(x = "low <-- Detailed occupations ranked by hourly wage --> high",
       y = "Change in share of total employment 
       \n (before --> during Covid-19 pandemic)", 
       caption = "Source: EBB & SPOLIS 2017-2022",
       color = "") +
  theme_minimal() +
  theme(axis.text.x=element_blank(),
        legend.position="bottom")

ggsave("SUPP_occ_comp_change.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)

ggplot(occ_comp, aes(y = empl_chng, x = r_hwage, colour = ess, size=p0, weight=p0)) +
  geom_hline(yintercept=0) +
  geom_point() +
  geom_smooth(method = "loess", formula = "y~x", se=FALSE, span=5) +
  geom_text_repel(data = subset(occ_comp, empl_chng<(-0.25) | empl_chng>0.25), 
                  mapping = aes(label = isco3), size=3, color="black") +
  guides(size = "none") +
  scale_y_continuous(breaks = seq(-1,1,0.25), limits = c(-1.03,1)) +
  scale_colour_manual(values = kandinsky) +
  labs(x = "low <-- Detailed occupations ranked by hourly wage --> high",
       y = "Change in share of total employment 
       \n (before --> during Covid-19 pandemic)", 
       caption = "Source: EBB & SPOLIS 2017-2022",
       color = "") +
  theme_minimal() +
  theme(axis.text.x=element_blank(),
        legend.position="bottom")

ggsave("SUPPalt_occ_comp_change.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)

ggplot(occ_comp, aes(y = empl_chng, x = r_hwage, colour = ess, size=p0, weight=p0)) +
  geom_hline(yintercept=0) +
  geom_point() +
  geom_smooth(method = "loess", formula = "y~x", se=FALSE, span=5) +
  geom_text_repel(data = subset(occ_comp, empl_chng<(-0.25) | empl_chng>0.25), 
                  mapping = aes(label = isco3), size=3, color="black") +
  guides(size = "none") +
  scale_y_continuous(breaks = seq(-1,1,0.25), limits = c(-1.03,1)) +
  scale_colour_grey() +
  labs(x = "low <-- Detailed occupations ranked by hourly wage --> high",
       y = "Change in share of total employment 
       \n (before --> during Covid-19 pandemic)", 
       caption = "Source: EBB & SPOLIS 2017-2022",
       color = "") +
  theme_minimal() +
  theme(axis.text.x=element_blank(),
        legend.position="bottom")

ggsave("SUPPalt_occ_comp_change_BW.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)


# S16 - Event Study Plot
ggplot(event_study, aes(y = coef, x = time_to_treat)) +
  geom_hline(yintercept=0, size=1) +
  geom_vline(xintercept=0, size=1, color = "grey") +
  geom_point(size = 2) +
  geom_line(size = 0.5) +
  geom_ribbon(aes(ymin = ci_bottom, ymax = ci_top),
              alpha=.5, linetype=0, size=2) +
  scale_x_continuous(breaks = seq(-13,10,1), limits = c(-13,10)) +
  labs(x = "Time to treatment",  
       y = "Treatment effect", 
       caption = "Source: EBB + SPOLIS, 2017-2022") +
  theme_minimal() +
  theme(legend.position="bottom")

ggsave("SUPP_eventstudy.pdf", path = "H:/Christoph/art3/05_figures", useDingbats = FALSE)
