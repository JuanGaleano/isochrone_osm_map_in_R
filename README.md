# isochrone_osm_map_in_R

I generally don't create GithHub repositories on demand, but yesterday I published a map on BlueSky and Michel Friendly asked about the blended color palette I have used. 
I have used articles and materials from Dr. Friendly in my dataviz and Digital Cartography classes so many times, that it's impossible to say no in this case.

You can see the map in question below.

![alt text](https://github.com/JuanGaleano/isochrone_osm_map_in_R/blob/main/12_osm_isochrone_2.png)     

## Context 

Every year I teach a course in Harbour Space university, in Bangkok, called "From Data to Knowledge". The course is devote to introduce bachelor and master students in Data Science to some of the most common techniques for visualizing statistical data and producing Digital Cartgoraphy. In session 8 we review how to access Open Street Maps data from R, how to geocode indformation and how to access the OpenRouteService from OSM. 

## Here you have a gpt-generated explanation of what is OpenRouteService     

OpenRouteService (ORS) is a powerful open-source routing platform that provides route planning and geospatial analysis services. It is built on top of OpenStreetMap (OSM) data and is designed for developers, researchers, and organizations that need routing and geospatial functionalities. Here are its main features and applications:

**Main Features**     

**Route Planning:** Provides optimized routes for various modes of transportation, such as driving, walking, cycling, wheelchair, and public transport.
Offers different types of routing profiles, including fastest, shortest, or environmentally friendly routes.            

**Isochrones:** Generates areas that can be reached within a certain time or distance from a specific location, useful for accessibility analysis.     

**Geocoding:** Converts addresses into geographic coordinates (forward geocoding) and vice versa (reverse geocoding).     

**Matrix Routing:** Calculates travel times or distances between multiple points, commonly used for logistics and delivery optimization.     

**Directions:** Provides turn-by-turn directions for navigation, including detailed steps, distances, and estimated travel times.      

**Accessibility Analysis:** Identifies areas that can be accessed within a certain time/distance under specific transportation conditions, helping in urban planning or service accessibility.      

**How It Works**     

ORS is powered by OpenStreetMap, which provides free and up-to-date geographic data.
The platform offers an API for integration into custom applications or workflows.
It can be accessed through their web interface or installed locally for private use.

## How to build and isochrone map combined with Open Street map data

The first thing you will need to do is to sign up and login in [Openroutservice](https://openrouteservice.org/). Once you have an account you need to get and api-key to use in your R session. 

**Step 1:** Set a starting point. For the present map I'm using the location coordinates of the [Staybridge Suites Bangkok Thonglor Hotel](https://www.ihg.com/staybridge/hotels/us/en/bangkok/bkkth/hoteldetail?cm_mmc=GoogleMaps-_-SB-_-TH-_-BKKTH), where I stay while in Bangkok.       

**Step 2:** Create a sf isochrone object using the location coordinates and setting a profile (foot-walking), range, interval and output. Also convert the values into minutes within a factor vector.        

**Step 3:** Crop your sf isochrone layer.    

**Step 4** Get a map tile of the reference area.        

**Step 5:** Create a color palette with the same lenght as intervals you have in the sf isochrone object.       

**Step 6:** You can plot a first version of the isochrone map. It will look like the following image. 

![alt text](https://github.com/JuanGaleano/isochrone_osm_map_in_R/blob/main/9_isochrone_walking.png)   

**Step 7:** Before accesing OSM data, check if you have invalid geometries in your sf isochrone object. And fix them if that's the case.       

**Step 8:** Get streets data from Open Street Maps for your area of referecence. And extract the data into a sf object. 












