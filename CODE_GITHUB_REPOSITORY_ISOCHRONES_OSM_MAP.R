library(tidyverse)
library(sf)
library(ggmap)
library(osmdata)
library(RColorBrewer)

assign("has_internet_via_proxy", TRUE, environment(curl::has_internet))

# 1. Set a starting point #####

coordinates <- data.frame(lon = c(100.580520702948 ), 
                          lat = c(13.728592483634944))


# 2. Create a sf isochrone object using the location coordinates ######
# and setting a profile (foot-walking), range, interval and output. 


walking <- ors_isochrones(locations = coordinates, 
                          profile = "foot-walking", 
                          range = 5400, 
                          interval = 600, 
                          output = "sf")

# Also convert the values into minutes within a factor vector. #####
walking<-walking|>
  mutate(mins=as.factor(value/60))

# 3. Crop your sf isochrone layer. #####
walking_cropped <- walking |>
  group_by(mins) |>
  st_intersection() |>
  ungroup()

# 4. Get a map tile of the reference area. ######
bbox <- st_bbox(walking_cropped)

# The only purpose of the following lines is to add some marginds to the map tile. You can adjust the margins changing the values which are now set to 1.1.
left<-(as.numeric(bbox[1])-mean(as.numeric(bbox[c(1,3)])))*1.1+mean(as.numeric(bbox[c(1,3)]))
right<-(as.numeric(bbox[3])-mean(as.numeric(bbox[c(1,3)])))*1.1+mean(as.numeric(bbox[c(1,3)]))
bottom<-(as.numeric(bbox[2])-mean(as.numeric(bbox[c(2,4)])))*1.1+mean(as.numeric(bbox[c(2,4)]))
top<-(as.numeric(bbox[4])-mean(as.numeric(bbox[c(2,4)])))*1.1+mean(as.numeric(bbox[c(2,4)]))

bkk_TILE_w<-get_stadiamap(bbox = c(left = left, 
                                   bottom = bottom, 
                                   right = right,
                                   top = top ), 
                          zoom = 14,  
                          maptype = c("stamen_toner"), 
                          crop = TRUE,
                          messaging = FALSE)

bkk_TILE_w <- ggmap(bkk_TILE_w)
bkk_TILE_w

# 5. Create a color palette with the same lenght as intervals you have in the sf isochrone object.####

colpal <- c(brewer.pal(9, "YlOrRd"))

# 6. You can plot a first version of the isochrone map ######

walking_map <-bkk_TILE_w +
  geom_sf(data = walking_cropped,
          aes(fill = (mins),color = (mins)),
          linewidth = .2,
          alpha = .5,
          inherit.aes = F)+
  scale_fill_manual(name = "Minutes",values = colpal) +
  scale_color_manual(values = colpal) +
  guides(
    color = "none",
    fill = guide_legend(
      nrow = 1,
      byrow = T,
      keyheight = unit(5, "mm"),
      keywidth = unit(15, "mm"),
      title.position = "left",
      label.position = "bottom",
      label.hjust = .5)) +
  labs(title = "Walking distance from my hotel in Bangkok")+
  theme_bw() +
  theme(
    plot.title = element_text(size=25,color  =  "black", face="bold",hjust = .5),
    legend.text = element_text(size=15,color  =  "black"),
    legend.title = element_text(size=15,color  =  "black"),
    legend.position = "bottom",
    axis.title = element_blank(),
    axis.text = element_blank()) 

walking_map

ggsave(
  "9_isochrone_walking.png",
  plot = walking_map,
  scale = 1,
  dpi = 300,
  height = 12,
  width = 11
)


# COMBINE OSM DATA AND ISOCHRONES #######

# 7. Before accessing OSM data, check if you have invalid geometries in your sf isochrone object. And fix them if that's the case.#####

invalid <- st_is_valid(walking)
print(which(!invalid))
walking <- st_make_valid(walking)

# 8. Get streets data from Open Street Maps for your area of referecence. And extract the data into a sf object.######

st_bbox(walking)

x <- c(100.52125, 100.63756 )
y <- c(13.66689 , 13.78735  )

custom_bkk <- rbind(x,y) 
colnames(custom_bkk) <- c("min", "max")

streets_osm <- custom_bkk %>%
  opq() %>%
  add_osm_feature(key = "highway", 
                  value = c("motorway", 
                            "primary", 
                            "secondary", 
                            "tertiary",
                            "trunk", 
                            "primary_link", 
                            "secondary_link", 
                            "tertiary_link",
                            "residential", 
                            "living_street",
                            "unclassified",
                            "residential",
                            "service", 
                            "footway")) %>%
  osmdata_sf()

# Extract the lines into a sf_object ######
streets_bkk<-streets_osm[["osm_lines"]]

ggplot()+
  geom_sf(data=streets_bkk)

# 9. Crop the streets map by intersecting them with the isochrone layer ######

street_inter<- st_intersection(walking,streets_bkk)

ggplot()+
  geom_sf(data=street_inter)

# 10. Plot your final map combining OSM data on the street of Bangkok with the isochrone sf object #####

map<-bkk_TILE_w +
  geom_sf(
    data = walking_cropped,
    aes(fill = (mins), color = (mins)),
    linewidth = .2,
    alpha = .5,
    inherit.aes = F)+
  geom_sf(data = street_inter,
          aes(geometry = geometry),
          color = "#060606",
          linewidth = .2,
          alpha = 1,
          inherit.aes = FALSE) +
  scale_fill_manual(name = "Minutes",values = colpal)  +
  scale_color_manual(values = colpal) +
  guides(
    color = "none",
    fill = guide_legend(
      nrow = 1,
      byrow = T,
      keyheight = unit(5, "mm"),
      keywidth = unit(15, "mm"),
      title.position = "left",
      label.position = "bottom",
      label.hjust = .5)) +
  labs(title = "Walking distance from my hotel in Bangkok",
       caption="Data: OpenStreetMaps & OpenRouteService. Elaboration: Juan Galeano")+
  theme_bw() +
  theme(
    plot.title = element_text(size=25,color  =  "black", face="bold",hjust = .5),
    plot.caption = element_text(lineheight=1, size=30/2,  hjust = 0.5,
                                colour="#bdbdbd",face="bold"),
    legend.text = element_text(size=15,color  =  "black"),
    legend.title = element_text(size=15,color  =  "black"),
    legend.position = "bottom",
    axis.title = element_blank(),
    axis.text = element_blank()) 

map


ggsave(
  "osm_isochrone.png",
  plot = map,
  scale = 1,
  dpi = 300,
  height = 12,
  width = 11
)




