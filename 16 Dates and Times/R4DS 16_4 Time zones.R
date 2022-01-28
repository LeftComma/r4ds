library(tidyverse)
library(lubridate)
library(nycflights13)


# Time zones are super complicated
# R uses the international IANA standard for time zones
# This uses the format <continent>/<city> e.g. Europe/Paris
# This is because individual places often change the times they use
# https://www.iana.org/time-zones <- they have a list of the complete history of all changes

# Find your current time zone
Sys.timezone()

# OlsonNames() is the list of all the names
length(OlsonNames())
head(OlsonNames())

# These are all the same instant in time
(x1 <- ymd_hms("2015-06-01 12:00:00", tz = "America/New_York"))
(x2 <- ymd_hms("2015-06-01 18:00:00", tz = "Europe/Copenhagen"))
(x3 <- ymd_hms("2015-06-02 04:00:00", tz = "Pacific/Auckland"))

# This can be verified using subtraction
x1 - x2
x1 - x3

# lubridate always uses UTC (Coordinated Universal Time) unless specified otherwise
# UTC is the computing standard, similar to GMT but without daylight savings

# Combining date-times often drops the zone, and displays it in the first zone in the list
x4 <- c(x1, x2, x3)
x4

# You can change the time zone but keep the instant in time the same
x4a <- with_tz(x4, tzone = "Australia/Lord_Howe")
x4a

x4a - x4

# Or you can change the instant, in case this has been mislabled or something
x4b <- force_tz(x4, tzone = "Australia/Lord_Howe")
x4b

x4b - x4
