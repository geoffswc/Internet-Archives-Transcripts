 ### Title: Assessing the risk and impact of the streetlamp effect on text analysis of digital archives.

### Proposal:

In this study, we propose to assess the impact of “streetlamp bias”, the observational effect of searching for something where it is easiest to find, on text analysis of documents drawn from digital media collections. 

### Problem Statement: 

Although AI methods for optical character recognition, image identification, and transcript extraction from digital media have advanced significantly over the last decade, transcript accuracy remains uneven across different document types. Furthermore, accuracy and completeness of transcript generation often varies based on media type. For example, an image containing cursive handwriting is unlikely to be transcribed as fully and accurately as typewritten text; similarly, a video with low audio quality where multiple people are speaking at once is unlikely to be transcribed as accurately as a mainstream news report. 

Because researchers often rely opaquely on technical staff to draw transcripts from large and diverse media collections, researchers may be unaware of bias that has been introduced into the dataset through transcription technologies or other text extraction methods. As a result, researchers are at risk of drawing erroneous general conclusions based on the partial subset that was accurately translated. 

From a sociological perspective, the variability of transcript accuracy may introduce a bias that causes studies to overlook or under consider perspectives from economically marginalized groups. For example, the “No More Silence” collection at the UCSF archives, which documents perspectives on the AIDS crisis across several decades, contains both handwritten letters from inmates in prison hospitals and typewritten documents from lawyers, physicians, and administrators at courts and in hospitals. A study that relies on current OCR transcription technology for topic modeling may be at risk of failing to consider perspectives from marginalized groups, as handwritten notes are far less likely to be translated accurately. 

For this study, we seek to assess the extent of this “streetlamp bias” risk through an investigation of three library collection topics: the AIDSs epidemic (“No More Silence”), the Tobacco industry (“Industry Documents”), and the opioid abuse epidemic. Through our identification of transcript accuracy in different media types in these collections, we will attempt to provide guidelines to researchers and technical staff for proper analysis, measurement, and reporting of transcript accuracy when working with digital media.  

### Methods:

Overview:

The general approach will involve comparing evaluated transcripts with computer generated transcripts. Through tagging, human transcription, and computer generated transcription, we will assess how accuracy may differ between media or document types, and how and whether this difference is more or less pronounced in certain categories. 

### Process: 

We will identify and sample a randomized subset of documents from each of the collections above, then generate text transcripts from image, audio, and video documents using Google AutoML tools. 

In parallel, a team of analysts will visually inspect and tag each document according to a set of criteria representing potential sources of bias. This visual inspection will take place independently of the computer generated transcript process. Tagging criteria will include 1) a set of predetermined categories with a set vocabulary, and 2) a variable set of categories established by the analysts as they categories the document collection. 

Tags may include:

file type 
image
video
audio
document source
court document
legal document
prison documents
community forum
commercial advertisements
handwriting type
hand printed
cursive note
typed
Subjective assessments (categorical, ordinal, or scored on a scale)
speaker clarity
multiple vs single speaker
mixed documents (e.g. printed surveys with handwritten responses)
Speech dialects or accents


