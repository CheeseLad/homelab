import sys
import os
directory = sys.argv[1]

print(f"Counting movies in {directory}...")

files = []

for filename in os.listdir(directory):
  files.append(filename)

print(f"Found {len(files)} movies in {directory}")

with open("movies.txt", "w") as f:
  for filename in files:
    f.write(f"{filename}\n")