require 'stanford-core-nlp'

StanfordCoreNLP.jar_path = Rails.root.join('nlp').to_s + "/"

# Set an alternative path to look for the model files
# Default is gem's bin folder.
StanfordCoreNLP.model_path = Rails.root.join('nlp').to_s + "/"

# Redirect VM output to log.txt
StanfordCoreNLP.log_file = Rails.root.join('log', 'nlp.log').to_s

StanfordCoreNLP::Config::AnnotationsByName['SentimentCoreAnnotations'] = ['nlp.sentiment']
StanfordCoreNLP.use :english
StanfordCoreNLP.default_jars = [
  'joda-time.jar',
  'xom.jar',
  'stanford-corenlp-3.5.0.jar',
  'stanford-corenlp-3.5.0-models.jar',
  'jollyday.jar',
  'bridge.jar',
  'ejml-0.23.jar'
]