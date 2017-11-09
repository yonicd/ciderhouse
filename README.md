# Orphan ideas that don't have a home yet

![](https://github.com/yonicd/ciderhouse/blob/master/tween_factor.gif?raw=true)

```r
library(animation)
library(ciderhouse)
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
```