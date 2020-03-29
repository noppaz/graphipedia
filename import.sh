#!/bin/bash
# Works as Docker and standalone import script
# For standalone running you need to package with maven first: mvn clean package
# Run with ./import.sh <wikipedia-pages-articles-multistream.xml.bz2> <output-directory>

if [ -z $1 ] && [ -z $2 ];
then
    echo "Usage: ./import.sh <wikipedia-pages-articles-multistream.xml.bz2> <output-directory>"
    exit 1
else
    INPUT_FILE=$1
    OUTPUT_DIR=$2
fi

bzip2 -dc $INPUT_FILE | java -classpath ./graphipedia-dataimport/target/graphipedia-dataimport.jar org.graphipedia.dataimport.ExtractLinks \
    - $OUTPUT_DIR/enwiki-links.xml

java -Xmx3G -classpath ./graphipedia-dataimport/target/graphipedia-dataimport.jar org.graphipedia.dataimport.neo4j.ImportGraph \
    $OUTPUT_DIR/enwiki-links.xml $OUTPUT_DIR/neo4jdb/databases/neo4j

#This is ugly, but for some reason the new database cannot be read by Neo4j 4.0.2, recreating metadata store on startup fixes the problem
rm -f $OUTPUT_DIR/neo4jdb/databases/neo4j/neostore