#!/usr/bin/python
import sys
import io
from urllib.request import urlopen, urlretrieve
from os import remove

# TODO: use a proper way to save json

URL_PREFIX = "https://www.kinopoisk.ru"
TOP_URL = URL_PREFIX+"/top/"
TOP_TEMP_PATH = "top.html"

DEFAULT_ENCODING = "cp1251"

MOVIES_COUNT = 250

IMAGES_DIR = 'kinometer/Posters'
OUTPUT = "kinometer/movies.json"

TOP250_FORMAT = "\"top250_place_%d\""
LINK_PREFIX = "href=\""

INFO_ID = "viewFilmInfoWrapper"
NAME_PROPERTY = "itemprop=\"name\""
ALTERNATIVE_PROPERTY = "alternativeHeadline"
IMAGE_METHOD = "openImgPopup('"
YEAR_PROPERTY = "m_act%5Byear%5D"
COUNTRY_PROPERTY = "m_act%5Bcountry%5D"
DIRECTOR_PROPERTY = "itemprop=\"director\""

def parse_property(html, after):
    begin = html.find('>', after) + 1
    end = html.find('<', begin)
    return (html[begin:end], end)

def save_image(rank, link):
    url = URL_PREFIX + link
    filename = "%s/%d.jpg" % (IMAGES_DIR, rank)
    urlretrieve(url, filename)


def parse_link(rank, link):
    url = URL_PREFIX + link
    html = urlopen(url).read().decode(DEFAULT_ENCODING, 'ignore')
    info_begin = html.find(INFO_ID)

    if info_begin < 0:
        raise Exception("Could not find %s" % INFO_ID)

    name, name_end = parse_property(html, html.find(NAME_PROPERTY, info_begin))

    alternative_property_begin = html.find(ALTERNATIVE_PROPERTY, name_end)
    if alternative_property_begin > 0:
        alternative, alternative_end = parse_property(html, alternative_property_begin)
    else:
        alternative = ""
        alternative_end = name_end

    image_begin = html.find(IMAGE_METHOD, alternative_end) + len(IMAGE_METHOD)
    image_end = html.find("'", image_begin)
    image_link = html[image_begin:image_end]
    save_image(rank, image_link)

    year, year_end = parse_property(html, html.find(YEAR_PROPERTY, image_end))
    country, country_end = parse_property(html, html.find(COUNTRY_PROPERTY, year_end))
    
    director_property_after = html.find('>', html.find(DIRECTOR_PROPERTY, country_end)) + 1
    director, directory_end = parse_property(html, director_property_after)

    return (name, alternative, int(year), country, director)

def save_data(data, filename):
    json = "["
    for name, alternative, year, country, director in data:
        if len(json) > 1:
            json += ","
        json += "\n\t{\n"
        json += "\t\t\"name\": \"%s\",\n" % name
        json += "\t\t\"alternative\": \"%s\",\n" % alternative
        json += "\t\t\"year\": %d,\n" % year
        json += "\t\t\"country\": \"%s\",\n" % country
        json += "\t\t\"director\": \"%s\"\n" % director
        json += "\t}"
    json += "\n]"

    with io.open(filename, "w", encoding="utf-8") as f:
        f.write(json)

def parse_file(filename, top_count):
    with io.open(filename,'r', encoding=DEFAULT_ENCODING) as f:
        html_content = f.read()

        prev_top_begin = 0

        data = []

        for i in range(top_count):
            top_place = TOP250_FORMAT % (i + 1)
            top_begin = html_content.find(top_place, prev_top_begin)
            link_begin = html_content.find(LINK_PREFIX, top_begin) + len(LINK_PREFIX)
            link_end = html_content.find('"', link_begin)
            link = html_content[link_begin:link_end]
            data.append(parse_link(i, link))
            prev_top_begin = link_end

        save_data(data, OUTPUT)

def load(url, filename, encoding):
    html = urlopen(url).read().decode(encoding)
    with io.open(filename, "w", encoding=encoding) as f:
        f.write(html)

if __name__ == "__main__":
    load(TOP_URL, TOP_TEMP_PATH, DEFAULT_ENCODING)
    parse_file(TOP_TEMP_PATH, MOVIES_COUNT)
    remove(TOP_TEMP_PATH)
