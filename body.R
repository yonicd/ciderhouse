library(animation)
ani.options(interval = 0.2)

set.seed(1)
dataf <- data.frame(
  x = c(rnorm(50,-1)-3, 3+rnorm(50,1),rnorm(50,1)-3,3+rnorm(50,1)),
  y = c(rnorm(50,-1)-3, 3+rnorm(50,1),6+rnorm(50,1),rnorm(50,-1)-3),
  group = rep(c(1,2,3,4), each=50)
)

chulls <- plyr::ddply(dataf, c('group'), function(df) df[chull(df$x, df$y), ])

x.in <- expand.grid(c(1:2),c(2:4))
x.in <- x.in%>%arrange(Var1)

x.in <- x.in[-c(2:4),]

dat_tween <- tween_factor(chulls,
                          levels = 'group',
                          direction.mat = x.in,
                          tweenlength =  3,
                          statelength = 0 ,
                          ease = 'linear', 
                          nframes = 10)

dat_tween <- dat_tween%>%mutate(.frame=ifelse(id>1,.frame+10,.frame))

p <- ggplot(data=dat_tween,aes(x=x,y=y)) + 
  geom_polygon(data=chulls,alpha=0.2,aes(x=x,y=y,fill=factor(group))) + 
  geom_point(aes(frame=.frame))
gganimate(p,filename = '~/tween_factor.gif')

library(ggmap)
library(rgdal)
map<-get_map(location='united states', zoom=4, maptype = "terrain",
             source='google',color='color')
f0 <- tempfile(fileext = '.geojson')
download.file("https://raw.githubusercontent.com/rstudio/leaflet/gh-pages/json/us-states.geojson",destfile = f0)
states <- geojsonio::geojson_read(f0, what = "sp")

p <- states@polygons
names(p) <- states$name

a <- plyr::ldply(p,function(x){
  out <- data.frame(x@Polygons[[1]]@coords) 
  names(out) <- c('lon','lat')
  out
},.id='name')%>%filter(name!='Maryland')

airport <- c('ATL','JFK','EWR','LAX')

x <- flights%>%
  left_join(airports@data%>%select(dest=faa,state),by='dest')%>%
  count(origin,state,dest)%>%
  group_by(state)%>%
  filter(max(n)==n)

x1 <- flights%>%
  right_join(x,by=c('origin','dest'))%>%
  filter(origin%in%c('EWR','JFK'))%>%
  group_by(origin,dest)%>%
  do(.,head(.,3))

x1$origin_state <- factor(x1$origin,labels=c('New Jersey','New York'))

x.in <- x1%>%ungroup%>%
  select(state,origin_state)%>%
  filter(complete.cases(.))

coordinates(airports) <- ~ lon + lat
proj4string(airports) <- proj4string(states)

airport_state <- over(airports,states)

airports$state <- airport_state$name

View(airports@data)



chull <- a

x.in <- expand.grid('Florida',c('California','New York'))

x.in <- data.frame(Var1='Florida',Var2='California',stringsAsFactors = FALSE)

dat_tween <- tween_factor(chull[,c(2,3,1)],
                          levels = 'name',
                          direction.mat = x.in[,c(2,1)],
                          tweenlength =  3,
                          statelength = 0 ,
                          ease = 'cubic-in-out', 
                          nframes = 50)


names(dat_tween)[c(3,4)] <- c('lon','lat')

dat_tween1 <- dat_tween%>%left_join(dat_tween%>%group_by(id)%>%
  filter(.frame==1)%>%
  select(id,lon_base=lon,lat_base=lat),by='id')

  
dat_tween1<-   plyr::ddply(dat_tween1,c('id','.frame'),
        function(x){
          dist=try({geosphere::distm (c(x$lon_base,x$lat_base), 
                            c(x$lon,x$lat), 
                            fun = geosphere::distGeo)})
          if(class(dist)=='try-error'){
            x$dist = NULL
          }else{
            x$dist <- as.numeric(dist)
          }
          x
        } )

dat_tween1 <- dat_tween1%>%filter(!is.na(dist))

dat_tween1 <- dat_tween1%>%mutate(.frame=ifelse(id%%2==0,.frame+10,.frame))

p0 <- ggmap(map) +
geom_polygon(aes(x = long, y = lat, group = group), 
             data = states,alpha=0,colour='black',size = 0.2)+
  geom_point(data=dat_tween1,aes(frame=.frame,colour=dist),show.legend = FALSE)+
  scale_colour_viridis(direction = -1,option='magma')

gganimate::gganimate(p0,filename = '~/tween_map.gif')
