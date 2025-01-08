Prepare Data for ML APIs on Google Cloud: Challenge Lab
#!/bin/bash

# Task 1: Run a simple Dataflow job
run_dataflow_job() {
  echo "Running Dataflow job..."
  gcloud dataflow jobs run "dataflow-job" \
    --gcs-location=gs://dataflow-templates/latest/TextIOToBigQuery \
    --region=us-central1 \
    --parameters inputFile=gs://cloud-training/gsp323/lab.csv,\
outputTable=qwiklabs-gcp-03-98a56141916e:lab_714.customers_791,\
tempLocation=gs://qwiklabs-gcp-03-98a56141916e-marking/temp,\
bigQueryLoadingTemporaryDirectory=gs://qwiklabs-gcp-03-98a56141916e-marking/bigquery_temp,\
schemaFile=gs://cloud-training/gsp323/lab.schema
}

# Task 2: Run a simple Dataproc job
run_dataproc_job() {
  echo "Setting up Dataproc cluster and running a job..."
  gcloud dataproc clusters create compute-engine-cluster \
    --region=us-central1 \
    --single-node \
    --master-machine-type=e2-standard-2 \
    --master-boot-disk-size=100GB

  gcloud dataproc jobs submit spark \
    --cluster=compute-engine-cluster \
    --region=us-central1 \
    --class=org.apache.spark.examples.SparkPageRank \
    --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
    -- "/data.txt"

  gcloud dataproc clusters delete compute-engine-cluster --region=us-central1 --quiet
}

# Task 3: Use Google Cloud Speech-to-Text API
run_speech_to_text() {
  echo "Running Speech-to-Text API..."
  gcloud ml speech recognize-long-running "gs://cloud-training/gsp323/task3.flac" \
    --language-code="en-US" \
    --format="LINEAR16" \
    --sample-rate-hertz=16000 > task3-gcs-963.result

  gsutil cp task3-gcs-963.result gs://qwiklabs-gcp-03-98a56141916e-marking/
}

# Task 4: Use the Cloud Natural Language API
run_natural_language_api() {
  echo "Running Natural Language API..."
  TEXT="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat."

  echo "$TEXT" > task4-input.txt
  gcloud ml language analyze-entities \
    --content "$TEXT" > task4-cnl-404.result

  gsutil cp task4-cnl-404.result gs://qwiklabs-gcp-03-98a56141916e-marking/
}

# Main Menu
main_menu() {
  echo "Choose a task to run:"
  echo "1. Run Dataflow job"
  echo "2. Run Dataproc job"
  echo "3. Run Speech-to-Text API"
  echo "4. Run Natural Language API"
  echo "5. Run All Tasks"
  echo "6. Exit"

  read -p "Enter your choice [1-6]: " choice

  case $choice in
    1) run_dataflow_job ;;
    2) run_dataproc_job ;;
    3) run_speech_to_text ;;
    4) run_natural_language_api ;;
    5) 
      run_dataflow_job
      run_dataproc_job
      run_speech_to_text
      run_natural_language_api
      ;;
    6) echo "Exiting..."; exit ;;
    *) echo "Invalid choice!"; main_menu ;;
  esac
}

main_menu
