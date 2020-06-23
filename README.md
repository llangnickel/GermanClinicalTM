## MedEx: Information extraction from German medical reports in the context of Alzheimer's Disease

As a lot of valuable information is not stored in machine-readable format, we built up information extraction pipelines to mine German medical reports.  
Because of a limited training data availability, the pipelines follow a rule-based approach making use of [UIMA Ruta](https://uima.apache.org/ruta.html).    
Due to data privacy, we can unfortunately not publish our data.  

## Pipeline overview 
![](img/workflow.png)

### Preprocessing
The preprocessing includes some basic steps, including a sentence detector, a tokenizer and a lemmatizer. For both the sentence detector and the tokenizer, regular expressions were used, which can be found [here](/preprocessing). The lemmatizer is from the [*Mate tools*](https://www.ims.uni-stuttgart.de/en/research/resources/tools/matetools/). 

### Named Entity Recognition 
We solved all NER tasks with the help of [UIMA Ruta](https://uima.apache.org/ruta.html). The source code and further information can be found [here](/RutaRules) 


