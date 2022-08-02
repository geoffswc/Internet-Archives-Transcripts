# Internet-Actives-Transcripts

Code and docs for Internet Archives Transcript Project

## Purpose and Background

Lubov draft & Geoff edit

#### Proposal:
The original IDL-DSI proposal for this project: Proposal.MD

## Extracting Videos and Metadata

### Gathering Metadata from the Internet Archives

To extract metadata from the Internet Archives, we used the the “search_items” and “download” methods from the internetarchives module, which provides an API to provided targeted search and downloads. 

https://internetarchive.readthedocs.io/en/stable/internetarchive.html

We retrieved metadata and links for all items in the ‘'UCSF Industry Archives Videos' collection, though we only ended up extracting transcripts for a small subset.

#### Script
download_from_ia.py

### Building a metadata dataframe

#### Overview:
The Internet Archives API downloads module provides methods to download metadata for for each item in a collection (along with other requested files). Files are downloaded locally to a directory named after the item identifier. To create a more analysis-friendly format, we extracted the following metadata elements into a pandas dataframe (which we later exported as a CSV)

For our study, we extracted:
* identifier    
* collection   
* title    
* mediatype    
* year    
* description    
* subject 
* file size
* file length
* url

 #### Workbook
 generate_links_metadata.ipynb

## Generating Video Transcripts

#### Overview: 

After identifying a subset of videos for analysis, we extracted transcripts from each URL using the Google AutoML API for transcription. This required a pipeline for transforming, downloading, extracting, and storing transcripts in a way that could be cross referenced with metadata. 

Google AutoML provides a transcription service to extract transcripts from audio files. Unfortunately, this does mean that we need  extract the audio file (in our case, we used a flac file) prior to using the transcription service. 

#### Process - for a list of URLs for mp4 files, this script 

* downloads the mp4 file from the URL (internet archives)
* uses ffmpeg to extract the .flac file 
* uploads the flac file to a google cloud storage bucket (a gs bucket URI is a requirement for using the transcription service)
* extracts the transcript from the flac file as a JSON file
* writes the JSON transcript to local storage

Note - this process very time consuming and can take over 20 minutes for a 2-3 hour file. You can speed this up by running the code on a google cloud cluster with multiple processors and/or splitting the load across multiple clusters. Total cost to process ~50 videos ranging from 2 minutes to 2 hours was around $100. 

#### workbook
file: extract_transcript_from_mp4_url.ipynb


## Data Curation

Lubov write

## Final Dataset Dictionary

Lubov write

## Analysis

Lubov write

### Conlcusions

Lubov write

## Uses

### Instructional Material

### Case Study
