# Internet-Actives-Transcripts

Code and docs for Internet Archives Transcript Project

## Purpose and Background

The Industry Documents Library is a vast collection of resources encompassing documents, images, videos, and recordings. These materials can be studied individually, but increasingly, researchers are interested in examining trends across whole collections, or subsets of it. In this way, the Industry Documents Library is also a trove of data that can be used to uncover trends and patterns in the history of industries impacting public health.

There are many ways to generate data from digital collections. In this project we focused on a combination of collections metadata and computer-generated transcripts of video files. We know that, like all information, data is not objective but constructed. Metadata is usually entered manually and is subject to human error. Video transcripts generated by computer programs are never 100% accurate. If accuracy varies based on factors such as the age of the video or the type of event being recorded, how might this impact conclusions drawn by researchers who are treating all video transcriptions as equally accurate? What guidance can the library provide to prevent researchers from drawing inaccurate conclusions from computer-generated text?

This project is a case study that evaluates the accuracy of computer-generated transcripts for videos within the Industry Documents Library’s Tobacco Collection. Specifically, the project investigates how transcript accuracy differs between television commercials and court proceedings. Other factors impacting accuracy, such as year and runtime, are also considered. These findings provide a foundation for UCSF's Industry Documents Library to create guidelines for researchers using video transcripts for text analysis. This case study also acts as a roadmap for similar studies to be conducted on other collections. 

#### Proposal:
Initial IDL-DSI project proposal: Proposal.MD

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
extract_transcript_from_mp4_url.ipynb

## Building Transcript Dataframes

We create a three dataframe with the transcript text, overall accuracy, min accuracy, max accuracy, and identifier name, which can be used to join with the metadata containing information on collection, title, mediatype, year, description, subject. Note that the AutoML transcription service assigns an accuracy score for each fraction of a transcript in short (often half-sentence) increments, so we calculated the average overall accuracy score for each transcript. As a result, a transcript with a high or low overall transcription accuracy rating based on the AutoML scores could have smaller sections with much lower or higher transcription accuracies. 

#### workbook
format_json.ipynb

## Sentiment Scores

Because we are interested in assessing how sentiment scores vary a transcript based on different attributes, we generate a sentiment score. In this case, we used the generally trained sentiment score from Google AutoML. We store the results in a tabular data format containing identifier, sentiment, and magnitude.

#### workbook 
Predict_Text_Sentiment.ipynb

## Topic Modeling

Because we drew our transcripts from two sources - legal documents and advertising documents, we ran a Kmeans topic model for two categories to see how closely AutoML matches the pre-determined categories. 

#### workbook
Topic-Modeling-Kmeans.ipynb

## Data Curation

In order to evaluate transcript accuracy between different factors, we created a dataset containing all variables of interest generated above. One observation (or row) of the dataset = one video in the collection. The dataset contains the variables described below.

### Final Dataset Dictionary

| Variable      | Description      | Source/Calculation            |
| ------------- | ---------------- | ----------------------------- |
| id            | Video identifier | Unique id from internetarchive|
| runtime| Length of the video (in seconds) | Metadata from internetarchive converted to seconds|
| category | Video type | Determined by us to be either "Advertising" or "Legal/Court" based on video content|
| url | Video URL | Metadata from internetarchive|
| year | Year of video | Metadata from internetarchive|
| fellow_accuracy_rating | One of "Poor," "Fair," "Good," or "Excellent" | Determined by junior data science fellows based on experience editing the computer transcript|
| automl_confidence_avg | Average Google AutoML confidence score for the transcript | Metadata from AutoML |
| automl_confidence_min | Minimum Google AutoML confidence score for the transcript | Metadata from AutoML |
| automl_confidence_max | Maximum Google AutoML confidence score for the transcript | Metadata from AutoML |
| computer_transcript | Computer-generated transcript | Generated from AutoML |
| human_transcript | Human-edited transcript | Transcript after editing by junior data science fellows |
| sentiment | Sentiment score of the computer-generated transcript | Generated from AutoML |
| magnitude | Sentiment magnitude of the computer-generated transcript | Generated from AutoML |
| human_sentiment | Sentiment of the human-edited transcript | Generated from AutoML |
| human_magnitude | Sentiment magnitude of the human-edited transcript | Generated from AutoML |
| war | [Word Accuracy Rate](https://en.wikipedia.org/wiki/Word_error_rate) | Calculated with python jiwer package |
| bleu_score | [BLEU Score](https://en.wikipedia.org/wiki/BLEU) | Calculated with python nltk package |

#### workbook
transcript_accuracy_assessment.ipynb

## Analysis

Finally, using the research dataset we created, we performed an analysis to investigate our research questions. Using R, we generated summary statistics, visualizations, and statistical tests. The findings from this analysis can be found in this [blog post](https://broughttolight.ucsf.edu/2022/08/31/contextualizing-data-for-researchers-a-data-science-fellowship-report/) summarizing the project. 

#### script
final_analysis_viz.R
