#!/bin/bash
rm /ppml/data/weekly-test/tpc-ds/performance/_SUCCESS

export secure_password=`openssl rsautl -inkey /ppml/password/key.txt -decrypt </ppml/password/output.bin`
bash bigdl-ppml-submit.sh \
        --master $RUNTIME_SPARK_MASTER \
        --deploy-mode cluster \
        --sgx-enabled true \
        --sgx-driver-jvm-memory 20g\
        --sgx-executor-jvm-memory 10g\
        --num-executors 8 \
        --driver-memory 20g \
        --driver-cores 8 \
        --executor-memory 10g \
        --executor-cores 8\
        --conf spark.cores.max=72 \
        --conf spark.kubernetes.driver.container.image=intelanalytics/bigdl-ppml-trusted-bigdata-gramine-reference-64g:$BIGDL_VERSION \
        --conf spark.kubernetes.executor.container.image=intelanalytics/bigdl-ppml-trusted-bigdata-gramine-reference-32g:$BIGDL_VERSION \
        --conf spark.kubernetes.container.image.pullPolicy=Always \
        --class "TPCDSBenchmark" \
        --conf spark.kubernetes.file.upload.path=file:///tmp \
        --conf spark.hadoop.javax.jdo.option.ConnectionURL="jdbc:derby:;databaseName=/ppml/data/shansimu/meta_db/1g_db;create=true" \
        --jars local:///ppml/data/shansimu/zoo-tutorials/tpcds-spark/spark-sql-perf/target/scala-2.12/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar \
        --name weekly-tpc-ds-on-gramine \
        --verbose \
        local:///ppml/data/shansimu/zoo-tutorials/tpcds-spark/target/scala-2.12/tpcds-benchmark_2.12-0.1.jar \
        /ppml/data/weekly-test/tpc-ds


if [ -f "/ppml/data/weekly-test/tpc-ds/performance/_SUCCESS" ]; then
        echo "TPC-DS test success!"
else
        echo "TPC-DS test failed!"
        exit 1
fi
