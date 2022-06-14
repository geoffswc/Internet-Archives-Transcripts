from internetarchive import search_items
from internetarchive import download
import os.path
import xmltodict
import pandas as pd

i = 0

dlnames = []

for item in search_items('UCSF Industry Archives Videos').iter_as_items():
    i += 1
    #print(i, 'item', item)
    #print(item.item_metadata['files'])
    identifier = item.item_metadata['metadata']['identifier']
    #download(identifier, verbose=True)
    download(identifier, verbose=True, glob_pattern='*.xml')

    filename = identifier + '/' + identifier + '_files.xml'
    if os.path.isfile(filename):
        xml_as_string = open(filename, 'r').read()
        d = xmltodict.parse(xml_as_string)
        
        for f in d['files']['file']:     
            
            if f['@name'].split('.')[-1] == 'mp4':  
                dl = f['@name']
                s = int(f['size'])
                url = 'https://archive.org/download/' + identifier + '/' + dl
                dlnames.append((identifier, dl, s, url))
        
    # parse the list
    
    #if i > 10:
    #    break
     
df = pd.DataFrame(dlnames, columns=['identifier', 'name', 'size', 'url'])

df.to_csv('dl.csv', index=False)
print(df)