#!/bin/bash

if [ -z $1 ] && [ -z $2 ];
then
    echo "Usage: ./import-docker.sh <wikipedia-pages-articles-multistream.xml.bz2> <output-directory>"
    exit 1
else
    INPUT_FILE=$1
    OUTPUT_DIR=$2
fi

echo "Build complete, starting import"

docker run --rm --volume=$INPUT_FILE:/input-file.xml.bz2 --volume=$OUTPUT_DIR:/output-data graphipedia

docker run --name neo4j \
--publish=7474:7474 --publish=7687:7687 \
--volume=$OUTPUT_DIR/neo4jdb:/data \
--env=NEO4J_AUTH=none \
-d neo4j:4.0.2

echo "Neo4j starting up, soon available at http://localhost:7474/"