Graphipedia
===========

A tool for creating a [Neo4j](http://neo4j.org) graph database of Wikipedia pages and the links between them. Updated version of [mirkonasato's](https://github.com/mirkonasato/graphipedia) original for Neo4j 4.

Building
--------

This is a Java project built with [Maven](http://maven.apache.org).

Check the `neo4j.version` property in the top-level `pom.xml` file and make sure it matches the Neo4j version
you intend to use to open the database. Then build with

    mvn package

This will generate a package including all dependencies in `graphipedia-dataimport/target/graphipedia-dataimport.jar`.

Importing Data
--------------

The graphipedia-dataimport module allows to create a Neo4j database from a Wikipedia database dump.

See [Wikipedia:Database_download](http://en.wikipedia.org/wiki/Wikipedia:Database_download)
for instructions on getting a Wikipedia database dump.

Assuming you downloaded `pages-articles-multistream.xml.bz2`, follow these steps:

1.  Run ExtractLinks to create a smaller intermediate XML file containing page titles
    and links only. The best way to do this is decompress the bzip2 file and pipe the output directly to ExtractLinks:

    `bzip2 -dc pages-articles-multistream.xml.bz2 | java -classpath graphipedia-dataimport.jar org.graphipedia.dataimport.ExtractLinks - enwiki-links.xml`

2.  Run ImportGraph to create a Neo4j database with nodes and relationships into
    a `neo4jdb` directory

    `java -Xmx3G -classpath graphipedia-dataimport.jar org.graphipedia.dataimport.neo4j.ImportGraph enwiki-links.xml neo4jdb/databases/neo4j`

These two steps are bundled in [import.sh](import.sh) for convenience.

Just to give an idea of runtime, enwiki-20200201-pages-articles-multistream.xml.bz2 is 16.6G and
contains almost 15M pages, resulting in over 160M links to be extracted. On a 2019 Macbook Pro laptop _with an SSD drive_ the import takes about 35 minutes to decompress/ExtractLinks (pretty much the same time
as decompressing only) and an additional 2 hours to ImportGraph.

(Note that disk I/O is the critical factor here: the same import will easily take several hours with an old 5400RPM drive.)

Using Docker
------------

A Dockerfile for running build and import in Docker is provided to enable running without bzip2, java and maven. Note that Docker on Mac doesn't perform as well as on Linux-based systems therefore importing with Docker on Mac will be very slow.

Regardless of import method, you can run Neo4j as a container on your imported database. Sample run command:

    docker run --name neo4j \
    --publish=7474:7474 --publish=7687:7687 \
    --volume=neo4jdb:/data \
    --env=NEO4J_AUTH=none \
    -d neo4j:4.0.2

Querying
--------

The [Neo4j browser](http://blog.neo4j.org/2013/10/neo4j-200-m06-introducing-neo4js-browser.html) can be used to query and visualise
the imported graph. Here are some sample Cypher queries.

Show all pages linked to a given starting page - e.g. "Neo4j":

    MATCH (p0:Page {title:'Neo4j'}) -[Link]- (p:Page)
    RETURN p0, p

Find how two pages - e.g. "Neo4j" and "Kevin Bacon" - are connected:

    MATCH (p0:Page {title:'Neo4j'}), (p1:Page {title:'Kevin Bacon'}),
      p = shortestPath((p0)-[*..6]-(p1))
    RETURN p
