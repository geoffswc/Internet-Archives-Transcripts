import urllib.request
import os
import glob
from google.cloud import storage
from google.cloud import speech
from google.protobuf.json_format import MessageToDict
import yaml
import json
import time
import pandas as pd

start_time = time.time()

with open('properties.yaml') as file:
    properties = yaml.full_load(file)

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = properties['google_application_credentials']

# cloud storage params
bucket_name = properties['bucket_name']
storage_client = storage.Client()
bucket = storage_client.bucket(bucket_name)

df = pd.read_csv('dl.csv')

for index, row in df.iterrows():

    url = 'https://archive.org/download/' + row['identifier'] + '/' + row['name']
    
    source_file_name = row['name']

    source_file_stem = row['identifier']

    #os.system('rm video_files/' + source_file_stem + '*.flac')
    #os.system('rm flac_files/' + source_file_name)

    print("downloading file")
    urllib.request.urlretrieve(url, 'video_files/' + source_file_name)
    print("run time:", time.time() - start_time)
    start_time = time.time()
    blob = bucket.blob("video_files/" + source_file_name)
    blob.upload_from_filename('video_files/' + source_file_name)

    # file needs to be in flac format
    print("converting to flac")

    os.system('ffmpeg -i video_files/' + source_file_name  + ' -c:a flac flac_files/' + source_file_stem + '.flac')
    
    print("uploading flac file to cloud")
    #blob = bucket.blob(source_file_name)
    blob = bucket.blob("flac_files/" + source_file_stem + '.flac')

    # upload
    blob.upload_from_filename('flac_files/' + source_file_stem + '.flac')
    print("run time:", time.time() - start_time)
    start_time = time.time()
    # extract transcript
      
    print("extracting transcript")
    client = speech.SpeechClient()
    
    gcs_uri = "gs://" + bucket_name  + "/" + row['identifier'] + "/" + source_file_stem + ".flac"
    
    #https://cloud.google.com/speech-to-text/docs/encoding    
    #You are not required to specify the encoding and sample rate for WAV or FLAC files. 
    #If omitted, Speech-to-Text automatically determines the encoding and sample rate for 
    #WAV or FLAC files based on the file header. 
    #If you specify an encoding or sample rate value that does not match the value in the 
    #file header, then Speech-to-Text returns an error.    
    # model='video' is not required, costs more, but might lead to better transcription
    
    audio = speech.RecognitionAudio(uri=gcs_uri)
    config = speech.RecognitionConfig(
        #encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
        #sample_rate_hertz=16000,
        audio_channel_count=2,
        language_code="en-US",
        use_enhanced=True,
        model='video',
        enable_word_time_offsets=True
    )

    operation = client.long_running_recognize(config=config, audio=audio)
    response = operation.result()
    print("run time:", time.time() - start_time)
    start_time = time.time()

    print("writing locally to json")
    result_dict = MessageToDict(response.__class__.pb(response))

    with open('json_output/' + source_file_stem + '.json', 'w') as fp:
        json.dump(result_dict, fp)
    print("run time:", time.time() - start_time)
    start_time = time.time()

    blob = bucket.blob("json_output/" + source_file_stem + '.json')
    blob.upload_from_filename('json_output/' + source_file_stem + '.json')
    
    #print('response', response)    

    #for result in response.results:
        # The first alternative is the most likely one for this portion.
        #print(u"Transcript: {}".format(result.alternatives[0].transcript))
        #print()
        #print("Confidence: {}".format(result.alternatives[0].confidence))
        #print()
    
        #print(result)

    #leave it there
    #print("cleanup")
    #blob.delete()
    #os.system('rm video_files/' + source_file_stem + '.flac')
    #os.system('rm flac_files/' + source_file_name)

    print("run time:", time.time() - start_time)
    start_time = time.time()
    
    break



