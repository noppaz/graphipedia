#!/bin/bash

if [ -z $1 ] && [ -z $2 ];
then
    echo "Usage: ./import-docker.sh <wikipedia-pages-articles-multistream.xml.bz2> <output-directory>"
    exit 1
else
    INPUT_FILE=$1
    OUTPUT_DIR=$2
fi

docker run --rm \
    -v $INPUT_FILE:/input-file.xml.bz2:cached \
    -v $OUTPUT_DIR:/output-data:delegated \
    graphipedia

docker run --rm \
    --name neo4j \
    -p 7474:7474 \
    -p 7687:7687 \
    -v $OUTPUT_DIR/neo4jdb:/data:delegated \
    -e NEO4J_AUTH=none \
    -d neo4j:4.0.2

echo "Neo4j starting up, soon available at http://localhost:7474/"
