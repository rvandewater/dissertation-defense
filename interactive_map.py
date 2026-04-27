
#| title: "World Map"
#| echo: false
#| warning: false
#| message: false
#| fig-cap: ""

import json
from urllib.request import urlopen
import base64
from ipyleaflet import GeoJSON, Map, Marker, DivIcon, Icon
from ipywidgets import HTML as WHTML
from IPython.display import HTML as IPHTML, display

# Set ocean (map container background) to pure white.
# This works because we remove all tile layers — the container
# background IS the ocean. No CSS filter hacks needed.
display(IPHTML(
    '<style>.leaflet-container { background: #ffffff !important; }</style>'
))

sites = [
    {"name": "Mount Sinai Health System, NYC",    "lat": 40.7128, "lon": -74.0060, "boston": False},
    {"name": "MIMIC-IV, Boston",                  "lat": 42.3601, "lon": -71.0589, "boston": True},
    {"name": "NWICU, Evanston, Illinois",          "lat": 42.0451, "lon": -87.6877, "boston": False},
    {"name": "EHRSHOT, Palo Alto",                "lat": 37.4419, "lon": -122.1430, "boston": False},
    {"name": "AUMCdb, Amsterdam",                 "lat": 52.3676, "lon":   4.9041, "boston": False},
    {"name": "HiRID, Basel",                      "lat": 47.5596, "lon":   7.5886, "boston": False},
    {"name": "SICdb, Salzburg",                   "lat": 47.8095, "lon":  13.0550, "boston": False},
    {"name": "INSPIRE, South Korea",              "lat": 37.5665, "lon": 126.9780, "boston": False},
]

# Build map with NO tile layers — blank white canvas
m = Map(
    center=(30.0, 10.0),
    zoom=1,
    scroll_wheel_zoom=True,
    zoom_control=False,
    attribution_control=False,
)
m.layout.height = "320px"

# Remove the default OSM tile layer that ipyleaflet adds automatically
for layer in list(m.layers):
    m.remove(layer)

# Add simplified world land polygons as the only visual layer
with urlopen(
    "https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson"
) as resp:
    world_geo = json.load(resp)

m.add(GeoJSON(
    data=world_geo,
    style={
        "fillColor":   "#dbd5cc",   # warm light gray land
        "fillOpacity": 1,
        "color":       "#c5bfb6",   # subtle country borders
        "weight":      0.6,
    },
))

# ── SVG teardrop pin via DivIcon ─────────────────────────────────────────
# Embedding the SVG directly in .html avoids any Leaflet CSS dependency
# (the source of the white-rectangle artifact with AwesomeIcon).
# icon_anchor=[6,20] pins the tip — not the centre — to the coordinate.


def _pin(color: str) -> Icon:
    # Encode SVG as a data URI → renders as <img>, transparent outside the shape,
    # no DivIcon wrapper div, no white rectangle possible
    svg = (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 20">'
        f'<path d="M6 0C2.686 0 0 2.686 0 6c0 5.25 6 14 6 14s6-8.75 6-14C12 2.686 9.314 0 6 0z"'
        f' fill="{color}" stroke="#ffffff" stroke-width="1.5"/>'
        f'<circle cx="6" cy="6" r="2.2" fill="#ffffff"/>'
        '</svg>'
    )
    b64 = base64.b64encode(svg.encode()).decode()
    return Icon(
        icon_url=f"data:image/svg+xml;base64,{b64}",
        icon_size=[12, 20],
        icon_anchor=[6, 20],
        shadow_url="",          # disable the default Leaflet drop-shadow
        shadow_size=[0, 0],
    )

red_pin    = _pin("#c0392b")   # red  — all external sites
boston_pin = _pin("#2c3e50")   # dark charcoal — Boston / MIMIC-IV

for s in sites:
    marker = Marker(
        location=(s["lat"], s["lon"]),
        title=s["name"],
        icon=boston_pin if s["boston"] else red_pin,
        draggable=False,
    )
    marker.popup = WHTML(f"<b>{s['name']}</b>")
    m.add(marker)

lat_vals = [s["lat"] for s in sites]
lon_vals = [s["lon"] for s in sites]
padding_deg = 15
m.fit_bounds((
    (min(lat_vals) - padding_deg, min(lon_vals) - padding_deg),
    (max(lat_vals) + padding_deg, max(lon_vals) + padding_deg),
))

m
