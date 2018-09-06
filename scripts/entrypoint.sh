#!/bin/sh

args=$@

echo "Commands: ${args}"

for i in $args
do
case $i in
--env=*)
environment="${i#*=}"
shift # past argument=value
;;
*)
# unknown option
;;
esac
done

if [ "${environment}" = "production" ]
then
echo 'waiting for db to come up'
./wait-for.sh db:5432 --timeout=60 || exit 1
fi
echo "starting server with ${args}"
./Run $args

exit $?
