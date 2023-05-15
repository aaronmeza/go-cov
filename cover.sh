#!/bin/bash

t="/tmp/cover.$$.tmp"
go test -cover -covermode=set -coverprofile=$t $@ `go list ./... | grep -v tests`


# Add file exclusions to exclude-from-code-coverage.txt
# One use case for this is removing generated code from the report. these files can be identified with the following command:
grep -lr "DO NOT EDIT" | grep ".go" >> exclude-from-code-coverage.txt

# Remove any entries in the coverprofile that are part of an excluded file
while read p || [ -n "$p" ]
do
sed -i '' "/${p//\//\\/}/d" $t
done < ./exclude-from-code-coverage.txt

go tool cover -html=$t


# Parse the coverprofile to get total line count and lines covered by tests
# the format of the coverprofile is
# name.go:line.column,line.column numberOfStatements count

coveredStatements=$(tail -n +2 $t | cut -d ' ' -f 3 | paste -sd+ - | bc -l)
echo "Covered statements: $coveredStatements"
totalStatements=$(tail -n +2 $t | cut -d ' ' -f 2 | paste -sd+ - | bc -l)
echo "Total statements: $totalStatements"
printf "Coverage: %2.0f%%\n" "$(bc <<< "scale=2; $coveredStatements / $totalStatements * 100")"
echo "coverprofile saved to: $t"
