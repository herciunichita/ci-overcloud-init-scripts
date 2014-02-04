#!/bin/bash

cd /opt/stack/tempest

testr init

TEMPEST_DIR="/home/ubuntu/tempest"
EXCLUDED_TESTS="$TEMPEST_DIR/excluded_tests.txt"

mkdir -p "$TEMPEST_DIR"

# make a list of excluded tests
testr list-tests tempest.api.compute | grep "rescue\|_uptime\|_console_\|AttachInterfaces" > "$EXCLUDED_TESTS" || echo "failed to generate exclude list"

testr run --parallel --subunit  --load-list=$EXCLUDED_TESTS |  subunit-2to1  > /home/ubuntu/tempest/subunit-output.log 2>&1
cat /home/ubuntu/tempest/subunit-output.log | /opt/stack/tempest/tools/colorizer.py > /home/ubuntu/tempest/tempest-output.log 2>&1
# testr exits with status 0. colorizer.py actually sets correct exit status
RET=$?
cd /home/ubuntu/tempest/
python /home/ubuntu/bin/subunit2html.py /home/ubuntu/tempest/subunit-output.log

exit $RET