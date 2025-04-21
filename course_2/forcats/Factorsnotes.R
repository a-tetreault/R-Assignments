library(tidyverse)
factor(x) # displays all factor levels stored in var x
month_levels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
x <- c("Jan", "May", "May", "Fez", "Mar", "Oct")
x1 <- factor(x, levels = month_levels) # create a vector out of x where the values are associated with month levels (factored now)
# Note how it leaves out (NA) any value ("Fez") that's misspelled or not in the factor levels
# Sometimes you’d prefer that the order of the levels match the order of the first appearance in the data. 
# You can do that when creating the factor by setting levels to unique(x), or after the fact, with fct_inorder():
f1 <- factor(x1, levels = unique(x1))
f2 <- x1 %>% factor() %>% fct_inorder()
# to access the valid levels of a vector use:
levels(x1)

# When factors are stored in a tibble, it's not so easy to see their factors
# one way to access them is to either use count for a column (displays all unique column ids and their counts)
# or using something like a bar chart that does the same thing, but visually
gss_cat %>% count(race)
gss_cat %>% ggplot(aes(race)) + geom_bar()

# fct() is a stricter version of factor() that errors 
# if your specification of levels is inconsistent w/ x values
# Use factors when you know the set of possible values a variable might take
x <- c("A", "O", "O", "AB", "A")
fct(x, levels = c("O", "A", "B", "AB"))

# If you don't specify the levels, fct will create from the data
# in the order that they're seen
fct(x) # levels o/p = "A", "O", "AB"

# factor() silently generates NAs
x <- c("a", "b", "c")
factor(x, levels = c("a", "b"))
#> [1] a    b    <NA>
#> Levels: a b
# fct() errors
try(fct(x, levels = c("a", "b")))
#> Error in fct(x, levels = c("a", "b")) : 
#>   All values of `x` must appear in `levels` or `na`
#> ℹ Missing level: "c"
# Unless you explicitly supply NA:
fct(x, levels = c("a", "b"), na = "c")
#> [1] a    b    <NA>
#> Levels: a b

# factor() sorts default levels:
factor(c("y", "x"))
#> [1] y x
#> Levels: x y
# fct() uses in order of appearance:
fct(c("y", "x"))

# 15.3.1 Exercise
# 1. Explore the distribution of rincome (reported income). What makes the default bar chart hard to understand? How could you improve the plot?
# you can't tell if it's monthly, yearly, or what. Also, the count doesn't really sho anything.
# we could do color = factor(relig or race or whatever factor we want to disambiguate by)

# 2. What is the most common relig in this survey? What’s the most common partyid?
gss_cat %>% count(relig) # Protestant n = 10846, next highest is None w/ 3523

gss_cat %>% count(party) # Independent n = 4119

# 3. Which relig does denom (denomination) apply to? How can you find out with a table? How can you find out with a visualisation?
gss_cat %>% count(relig, denom) # gives boh and the only answers that aren't applicable or no answer are in Christian

gss_cat %>% ggplot(aes(relig, color = factor(denom))) + geom_bar() # only in protestant does any factor sho up other than "No Answer" "Don't Know"

# fct_reorder(f, x, fun) takes three arguments:

# f, the factor whose levels you want to modify.
# x, a numeric vector that you want to use to reorder the levels.
# Optionally, fun, a function that’s used if there are
# multiple values of x for each value of f. default is median.

relig_summary <- gss_cat %>% 
    group_by(relig) %>% 
    summarize(
        age = mean(age, na.rm = TRUE),
        tvhours = mean(tvhours, na.rm = TRUE),
        n = n()
    )
ggplot(relig_summary, aes(tvhours, relig)) + 
    geom_point()
# It is difficult to interpret this plot because there’s no overall pattern. 
# We can improve it by reordering the levels of relig using fct_reorder().
ggplot(relig_summary, aes(tvhours, fct_reorder(relig, tvhours))) + 
    geom_point()
# Another way to accomplish this is to mutate the relig col first then plot
relig_summary %>% 
    mutate(relig = fct_reorder(relig, tvhours)) %>% 
    ggplot(aes(tvhours, relig)) +
    geom_point()

# similar plot, looking at how average age varies across rincome
rincome_summary <- gss_cat %>% 
    group_by(rincome) %>% 
    summarize(
        age = mean(age, na.rm = TRUE),
        tvhours = mean(tvhours, na.rm = TRUE),
        n = n()
    )
ggplot(rincome_summary, aes(age, fct_reorder(rincome, age))) + geom_point()
# Here, arbitrarily reordering the levels isn’t a good idea! 
# That’s because rincome already has a principled order that we shouldn’t mess with. 
# Reserve fct_reorder() for factors whose levels are arbitrarily ordered.
# However, it does make sense to pull “Not applicable” to the front with the other special levels.
# You can use fct_relevel(f, x). It takes a factor, f, and then any x number of levels to moved to the front.
ggplot(rincome_summary, aes(age, fct_relevel(rincome, "Not applicable"))) + geom_point()

# Another type of reordering is useful when you want colored lines on a plot. 
# fct_reorder2() reorders the factor by the y values associated with the largest x values. 
# This makes the plot easier to read because the line colours line up with the legend.
by_age <- gss_cat %>% 
    filter(!is.na(age)) %>% 
    count(age, marital) %>% 
    group_by(age) %>% 
    mutate(prop = n / sum(n))
ggplot(by_age, aes(age, prop, color = marital)) +
    geom_line(na.rm = TRUE)
# reorders by most to lowest 
ggplot(by_age, aes(age, prop, color = fct_reorder2(marital, age, prop))) +
    geom_line() +
    labs(color = "marital")

# Finally, for bar plots, you can use fct_infreq() to order levels in increasing frequency: 
# this is the simplest type of reordering because it doesn’t need any extra variables. 
#You may want to combine with fct_rev(). (reverse order of factor levels)
gss_cat %>% 
    mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>% 
    ggplot(aes(marital)) +
        geom_bar()

# 15.4.1 Exercises
# 1. There are some suspiciously high numbers in tvhours. Is the mean a good summary?
relig_summary <- gss_cat %>% 
    group_by(relig) %>% 
    summarize(
        age = mean(age, na.rm = TRUE),
        tvhours = (tvhours, na.rm = TRUE),
        n = n()
    )
ggplot(relig_summary, aes(tvhours, fct_reorder(relig, tvhours))) + 
    geom_point()

# 2. For each factor in gss_cat identify whether the order of the levels is arbitrary or principled.
x4 <- names(gss_cat)
for (str in x4) {
    print(str_c("Levels for ", str, ":"))
    print(levels(gss_cat[[str]]))
}
# year and age have no levels associated (although they would be principled because they only go in one direction)
# rincome and tvhours are principled because it moves in one logical direction (monetary values go up in groupings so do hours watched)
# marital, race, partyid, relig, and denom are arbitrary because there is no logical order to them. fct_reorder() would be helpful to display them in the manner needed

# 3. Why did moving “Not applicable” to the front of the levels move it to the bottom of the plot?

# Lecture Examples
# 1. What are factors
dcclimate <- tribble(
    ~month, ~avehigh,
    ##----/----------
    "Jan",  43.4,
    "Feb",  47.1,
    "Mar",  55.9,
    "Apr",  66.6,
    "May",  75.4,
    "Jul",  88.4,
    "Aux",  86.5,
    "Sep",  79.5,
    "Oct",  68.4,
    "Nov",  57.9,
    "Dec",  46.8)
# currently the months are just characters, not months, so it won't order by month,
# They will order by alphabetical, so we will have to make them factors.
# mos will store the char vector for our levels
mos <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# now we'll add them as a factor to dcclimate
dcclimate %>% 
    mutate(monthfc = factor(month, levels = mos)) -> #assign in opposite direction
    dcclimate
# Here's the difference between factor and parse_factor
dcclimate %>% 
    mutate(monthfc2 = factor(month, levels = mos)) ->
    dcclimate
mos1 <- mos %>% factor() %>% fct_inorder()
dcclimate1 <- dcclimate %>% 
    mutate(monthfc = factor(month, levels = mos1))
fct_unique(dcclimate1$monthfc)
fct_unique(dcclimate1$month)
nlevels(dcclimate$monthfc) # count number of factors
ggplot(dcclimate, aes(x = monthfc, y = avehigh)) +
    geom_col() #this will not include anything for the missing values Jun or Aug (because Aux)
ggplot(dcclimate, aes(x = monthfc, y = avehigh)) +
    geom_col() +
    scale_x_discrete(drop = FALSE) # Do not drop missing values of factors
# still have weird NA value, we've got to deal with that.

# modifying factor order
df <- tribble(
    ~color,      ~a, ~b,
    "blue",     1,  2,
    "green",    6,  2,
    "purple",   3,  3,
    "red",      2,  3,
    "yellow",   5,  1
)
df$color <- factor(df$color)
# reorders from the smallest to highest level of df$a.
fct_reorder(df$color, df$a, min)
# [1] blue   green  purple red    yellow
# Levels: blue red purple yellow green
# 2 will get the highest level of the first one df$a then go in order by the second (b)
fct_reorder2(df$color, df$a, df$b)
# [1] blue   green  purple red    yellow
# Levels: purple red blue green yellow

# modifying factor levels
# fct_recode of gss_cat political party for easier reading
gss_cat %>% 
    mutate(partyid = fct_recode(partyid,
                                "Republican, strong"    = "Strong republican",
                                "Republican, weak"      = "Not str republican",
                                "Independent, near rep" = "Ind,near rep",
                                "Independent, near dem" = "Ind,near dem",
                                "Democrat, weak"        = "Not str democrat",
                                "Democrat, strong"      = "Strong democrat"
    )) %>% 
    count(partyid)
# fct_recode(col_to_change, "new value1" = "old value1", "new value 2" = "old value 2", etc.)
# We can also include multiple values into the same levels to collapse a bunch of levels
# either through mutate like we did before
gss_cat %>% 
    mutate(partyid = fct_recode(partyid,
                                "Republican, strong"    = "Strong republican",
                                "Republican, weak"      = "Not str republican",
                                "Independent, near rep" = "Ind,near rep",
                                "Independent, near dem" = "Ind,near dem",
                                "Democrat, weak"        = "Not str democrat",
                                "Democrat, strong"      = "Strong democrat",
                                "Other"                 = "No answer",
                                "Other"                 = "Don't know",
                                "Other"                 = "Other party"
    )) %>% 
    count(partyid)
# or we can use fct_collapse() to group old values into new ones
gss_cat %>% 
    mutate(partyid = fct_collapse(partyid,
                                  other = c("No answer", "Don't know", "Other party"),
                                  rep = c("Strong republican", "Not str republican"),
                                  ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                  dem = c("Not str democrat", "Strong democrat")
    )) %>% 
    count(partyid)
# we could also use fct_lump(col_to_lump, n = #lumps) to lump small categories together into an "Other"
gss_cat %>% 
    mutate(relig = fct_lump(relig, n = 10)) %>% 
    count(relig, sort = TRUE) %>% 
    print(n = Inf)
# picks out the top 9 groups (n - 1) groups and lumps the rest of them into an "other" category
    