#! /usr/bin/env bash

ROOT=$DNN_QUANT_ROOT
BIN=$ROOT/scripts
DATA_DIR=$ROOT/datasets
TRAIN_DIR=train-rnn
TRAIN_FILE=row-norm-all-100M.dat
CONFIG_FILE=rnn-gru-iter.conf
CHKPTS_NAME=chkpts-${TRAIN_DIR}

# make training directory if it does not exist
mkdir -p ${TRAIN_DIR}

GPU=3
START_YEAR=2015
END_YEAR=2015
YEAR=$START_YEAR

while [ $YEAR -le $END_YEAR ]
do
    TEST_START=${YEAR}01
    TEST_END=${YEAR}12
    TEST_END_W_PAD=`expr ${YEAR} + 1`01
    TEST_PRE=`expr ${YEAR} - 6`06
    TRAIN_END=`expr ${YEAR} - 2`12
    MODEL_DATE=201401

    FINAL_PREDICTIONS_FILE=${TRAIN_DIR}/test-preds-${TEST_START}.dat

    if [ ! -e $FINAL_PREDICTIONS_FILE ]; then
	echo "Creating test data set for ${TEST_START} to ${TEST_END} (Test pre is ${TEST_PRE})"
	$BIN/slice_data.pl $TEST_PRE $TEST_END_W_PAD < ${DATA_DIR}/${TRAIN_FILE} > ${TRAIN_DIR}/test-data-${TEST_START}.dat
	echo "Creating predictions file for period ${TEST_PRE} to ${TEST_END}"
	$BIN/classify_data.py --config=${CONFIG_FILE} --default_gpu=/gpu:${GPU} --model_dir=${CHKPTS_NAME}-${MODEL_DATE}  --print_start=${TEST_START} --print_end=${TEST_END} \
            --data_dir=. --test_datafile=${TRAIN_DIR}/test-data-${TEST_START}.dat --output=${TRAIN_DIR}/preds-${TEST_START}.dat > ${TRAIN_DIR}/results-${TEST_START}.txt
	echo "Slicing predictions file ${TEST_START} to ${TEST_END} to create ${FINAL_PREDICTIONS_FILE}"
	$BIN/slice_data.pl $TEST_START $TEST_END < ${TRAIN_DIR}/preds-${TEST_START}.dat > "${FINAL_PREDICTIONS_FILE}"
    fi

    YEAR=`expr $YEAR + 1`
done
