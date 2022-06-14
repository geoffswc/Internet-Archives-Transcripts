# https://archive.org/services/docs/api/internetarchive/quickstart.html#downloading

#from internetarchive import download
#download('tobacco_stkd0111', verbose=True, glob_pattern='*xml')
#download('tobacco_stkd0111', verbose=True, glob_pattern='*')

# search
#https://archive.org/services/docs/api/internetarchive/quickstart.html#searching
#https://archive.org/services/docs/api/internetarchive/api.html#internetarchive.search_items
from internetarchive import search_items
from internetarchive import download


# parsing a collection
# https://archive.org/services/docs/api/items.html?highlight=collection
#for item in search_items('identifier:tobacco_stkd0111').iter_as_items():
#    print('item', item)
#    print(item.item_metadata)

#for item in search_items('tobacco').iter_as_items():
#    i += 1
    #print('item', item)
    #print(item.item_metadata)
    
#print("***", i)
    
print(len(search_items('UCSF Industry Archives Videos')))

#print("****", len(search_items('Gotta love the pushy advertising of the 50s. ')))
#UCSF Industry Archives Videos

# 'industry-archives'
i = 0
for item in search_items('UCSF Industry Archives Videos').iter_as_items():
    i += 1
    #print(i, 'item', item)
    #print(item.item_metadata['files'])
    identifier = item.item_metadata['metadata']['identifier']
    #download(identifier, verbose=True)
    print(identifier)
    download(identifier, verbose=True, glob_pattern='*xml')
    
    if i > 4:
        break
    
