import json
import math
from tqdm import tqdm
import argparse
from pathlib import Path

from MAVProxy.modules.mavproxy_map.mp_elevation import ElevationModel

parser = argparse.ArgumentParser(description="Process all images for tracking")
parser.add_argument(
    "-g",
    "--geojson",
    help="Path to the geojson to download",
    type=str,
)

parser.parse_args()

geojson_path=Path(parser.geojson)
assert geojson_path.exists(), "geojson input needs to exist!"

with open(geojson_path, "r") as file:
    data = json.load(file)
    minLat = 99999
    minLon = 99999
    maxLat = -99999
    maxLon = -99999
    polygonPoints = data['features'][0]['geometry']['coordinates'][0]
    for onePoint in polygonPoints:
        minLon = min(minLon, onePoint[0])
        minLat = min(minLat, onePoint[1])
        maxLon = max(maxLon, onePoint[0])
        maxLat = max(maxLat, onePoint[1])

elevatioDownloader = ElevationModel(database='srtm', offline=0, debug=True)

minLat=minLat-1
maxLat=maxLat+1
minLon=minLon-1
maxLon=maxLon+1
latRange = range(math.floor(minLat), math.ceil(maxLat))
lonRange = range(math.floor(minLon), math.ceil(maxLon))

pbar = tqdm(total=len(latRange)*len(lonRange))
for lat in latRange:
    for lon in lonRange:
        pbar.set_description("Lat:{} Lon:{}".format(lat, lon))
        elevatioDownloader.GetElevation(lat, lon, timeout=5)
        pbar.update(1)
