#!/bin/bash

PKGS=`go list ./... | grep -v vendor/ | grep -v txdk/ | grep -v testing/`

EX_PACKAGE=(
)

for PKG in ${EX_PACKAGE[@]}
do
    PKGS=`echo $PKGS | tr " " "\n" | grep -v $PKG`
done

eval go test -count=1 -cover -race $PKGS | tee test.out

now=$(date --rfc-3339=ns)
echo "$now TEST RESULT..."

file_name=$1

file=$(cat "$file_name")
if [ "$file" == "" ]
then
    echo "FAIL: Test Result is Empty!!"
    exit 1
fi

failed_test=$(cat "$file_name" | grep -a "^FAIL\s")
no_test=$(cat "$file_name" | grep -a "no test files")
percentage_success=$(cat "$file_name" | grep -a "^ok\s" | awk '{ print $5 }')

failed_test_count=$(echo "$failed_test" | wc -l)
if [ "$failed_test" == "" ]
then
    failed_test_count=0
fi

if [ "$failed_test_count" -gt "0" ]
then
    echo "FAIL: Test Failed!!!"
    echo "$failed_test"
    exit 1
fi

no_test_count=$(echo "$no_test" | wc -l)
if [ "$no_test" == "" ]
then
    no_test_count=0
fi

if [ "$no_test_count" -gt "0" ]
then
    echo "WARNING: No Test Files!"
    echo "$no_test"
fi

percentage_success_count=$(echo "$percentage_success" | wc -l)
percentage_success_non_percent=${percentage_success//\%/}
percentage_success_non_percent=$(echo "$percentage_success_non_percent" | awk -F. '{ print $1 }')

percentage_total=0

if [ "$percentage_success_non_percent" != "" ]
then
    while read num_percent
    do
        percentage_total=$(($percentage_total + $num_percent))
    done <<< "$percentage_success_non_percent"
fi

test_count=$(($percentage_success_count + $no_test_count))
percentage_avg=$(($percentage_total / $test_count))

percentage_target=$2
if [ "$percentage_avg" -lt "$percentage_target" ]
then
    echo "FAIL: Average Coverage < $percentage_target%!"
    echo "Average coverage is below $percentage_target% (Currently $percentage_avg%)"
    echo "Please add more test first!"
    exit 2
fi

echo "SUCCESS"
echo "Test Exists :    $percentage_success_count from $test_count packages"
echo "Avg Coverage:    $percentage_avg%"
exit 0