#Compare and contrast the results of paste0() with str_c() for the following inputs:
    
str_c("hi ", NA)
str_c(letters[1:2], letters[1:3])

#What’s the difference between paste() and paste0()? How can you recreate the equivalent of paste() with str_c()?
    
#Convert the following expressions from str_c() to str_glue() or vice versa:
    
str_c("The price of ", food, " is ", price)
str_glue("The price of {food} is {price}")

str_glue("I'm {age} years old and live in {country}")
str_c("I'm ", age, " years old and live in ", country)

str_c("\\section{", title, "}")
str_glue("\\section{{{title}}}")
"$^$"
#Start with “y”.
words %>% 
    str_view("^y")

# End with “x”
words %>% 
    str_view("x$")

# Are exactly three letters long. (Don’t cheat by using str_length()!)
words %>% 
    str_view("^...$", match = TRUE)

# Have seven letters or more.
words %>% 
    str_view("^.......+", match = TRUE)

# 1. Create regular expressions to find all words that:
    
# Start with a vowel.
str_view(words, "^[aeiou]")

# That only contain consonants. (Hint: thinking about matching “not”-vowels.)
str_view(words, "^[^aeiou]*$")

# End with ed, but not with eed.
str_view(words, "^.*[^e]ed$")

# End with ing or ise.
str_view(words, "(ing|ise)$")

# 2. Empirically verify the rule “i before e except after c”.

# 3. Is “q” always followed by a “u”?
str_view(words, ".*q[^u].*") # seems not in this set of words.

# 4. Write a regular expression that matches a word if it’s probably written in British English, not American English.
str_view(words, "(e|a)")

# 5. Create a regular expression that will match telephone numbers as commonly written in your country.
# "^(\d{3}\)[ ]*\-*\d{3}[ ]*\-*\d{4}"
# ex. that includes almost every permutation
# "^(\d?{ (]?\d{3}\)?[ -]?\d{3}[ -]?\d{4}"

# Describe the equivalents of ?, +, * in {m,n} form.

# Describe in words what these regular expressions match: (read carefully to see if I’m using a regular expression or a string that defines a regular expression.)

# ^.*$
# any amount of characters. it's just start, zero or more characters, end.
# "\\{.+\\}"
# {any number of characters}
# \d{4}-\d{2}-\d{2}
# date YYY-MM-DD format
# "\\\\{4}"
# \\\\

# Create regular expressions to find all words that:
    
# Start with three consonants.
str_view(words, "^[^aeiou]{3}")

# Have three or more vowels in a row.
str_view(words, "[aeiou]{3,}")

# Have two or more vowel-consonant pairs in a row.
str_view(words, "([aeiou][^aeiou]){2,}")

# Describe, in words, what these expressions will match:
    
# (.)\1\1
# The first grouped element twice
# "(.)(.)\\2\\1"
# The second grouped element then the first grouped element
# (..)\1
# Any combination of two characters
# "(.).\\1.\\1"
# The first grouped element + "." + The first grouped element
# "(.)(.)(.).*\\3\\2\\1"
# The 3rd grouped element, the second grouped element, the first grouped element

# Construct regular expressions to match words that:
    
# Start and end with the same character.
str_view(words, "^(.).*\\1$")

# Contain a repeated pair of letters (e.g. “church” contains “ch” repeated twice.)
str_view(words, "(..).*\\1")

# Contain one letter repeated in at least three places (e.g. “eleven” contains three “e”s.)
str_view(words, "(.).*\\1.*\\1")

# 1. For each of the following challenges, try solving it by using both a single regular expression, and a combination of multiple str_detect() calls.

# Find all words that start or end with x.
str_detect(words, "(^x)|(x$)")

# Find all words that start with a vowel and end with a consonant.
str_detect(words, "^[aeiou].*[^aeiou]$")

# 2. Are there any words that contain at least one of each different vowel?
str_detect(words, "a+e+i+o+u+")

# 3. What word has the highest number of vowels? What word has the highest proportion of vowels? (Hint: what is the denominator?)
max(str_count(words, "[aeiou]+"))
d <- (str_count(words, "[aeiou]+")/str_count(words, ".*"))

# 1. In the previous example, you might have noticed that the regular expression matched “flickered”, which is not a colour. Modify the regex to fix the problem.

# 2. From the Harvard sentences data, extract:
s <- tibble(sentences)

# a. The first word from each sentence.
str_extract(sentences, "^.*?\\s")

# b. All words ending in ing.
str_extract_all(sentences, "[:space:]([:alnum:]+?ing)[:space:]", simplify = TRUE)

# c. All plurals.
str_extract_all(sentences, "[:alnum:]+?[aeiou]*?s")
