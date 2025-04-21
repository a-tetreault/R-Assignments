# Add the location of the origin and destination (i.e. the lat and lon) to flights.

flights %>% 
    left_join(airports %>% select(faa, lat, lon), join_by("origin" == "faa")) %>% 
    left_join(airports %>% select(faa, lat, lon), join_by("dest" == "faa")) %>% 
    rename(lat.origin = lat.x, lon.origin = lon.x, lat.dest = lat.y, lon.dest = lon.y) %>% 
    view()
naplanes <- planes %>% filter(tailnum == NA)
flights %>% 
    semi_join(planes,)
# mutating joins

x <- tribble(
    ~key,    ~val_x,
    #------/-------
    1,      "x1",
    2,      "x2",
    3,      "x3",
    3,      "x4"
)
y <- tribble(
    ~key,    ~val_y,
    #------/-------
    1,      "y1",
    2,      "y2",
    2,      "y3",
    4,      "y4"
)
inner_join(x,y)
left_join(x,y)
right_join(x,y)
full_join(x,y)

#filtering joins
#filter observations from one tibble
#based on whether they match with anot
semi_join(x,y)
anti_join(x,y)
# Semi_join good for finding top of something

top_dest <- flights %>% 
    count(dest, sort=TRUE) %>% 
    head(10)
flights %>% 
    semi_join(top_dest)

#anti_join good for finding if we have items missing
#flights in flights but not planes
fl <- flights %>% 
    anti_join(planes, by="tailnum") %>% 
    count(tailnum, sort=TRUE)
#check flights where tailnum is NA
flights %>% filter(is.na(tailnum))
#okay, is every departure time NA when tailnum is NA?
flights %>% filter(is.na(tailnum)) %>% 
    filter(!is.na(dep_time))
#Yes, turns out they make tailnum NA when flight is cancelled(don't have dep_time)

#Map!
airports %>% 
    semi_join(flights, by = c("faa" = "dest")) %>% 
    ggplot(aes(lon,lat)) + 
    borders("state") +
    geom_point() +
    coord_quickmap()

#set operations
x1 <- tribble(
    ~var1, ~var2,
    "a",    1,
    "b",    2,
    "c",    3
)
y1 <- tribble(
    ~var1,  ~var2,
    "a",    1,
    "c",    3,
    "d",    4
)

intersect(x1,y1) # which observations are the same in x and y?
union(x1,y1) # which observations are in x and not y?
setdiff(x1,y1) # which elements in y are not in x?


