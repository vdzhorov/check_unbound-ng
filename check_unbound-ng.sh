#!/bin/bash

#######################################################################
#                                                                     #
# This is a script that monitors Unbound DNS resolvers.               #
#                                                                     #
# The script uses unbound-control to check that Unbound is running,   #
# and to display the statistics as performace data. The oritginal     #
# script is forked from                                               #
# https://github.com/PanoramicRum/unbound-nagios-plugins              #
#                                                                     #
#                                                                     #
# Version 1.0 2024-11-05 Initial release                              #
#                                                                     #
# Licensed under the Apache License Version 2.0                       #
# Written by Valentin Dzhorov - vdzhorov@gmail.com                    #
#                                                                     #
#######################################################################


unboundcontrol="/usr/sbin/unbound-control stats"

# Help message
usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -a, --all                 No filtering is done to the output."
  echo "  -t, --total               Filter only results from 'total.*' at the output."
  echo "  -n, --num-query           Filter only results from 'num.query.*' field. at the output."
  echo "  -m, --mem                 Filter only results from 'mem.*' field. at the output."
  echo "  -r, --answer-rcode        Filter only results from 'num.answer.rcode.*' field at the output."
  echo "  -h, --help                Display this help message."
}

# Parse CLI options
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -a|--all) unbound_option="all"; shift ;;
    -t|--total) unbound_option="total"; shift ;;
    -n|--num-query) unbound_option="num_query"; shift ;;
    -m|--mem) unbound_option="mem"; shift ;;
    -r|--answer-rcode) unbound_option="answer_rcode"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

# Main logic
if [[ "$unbound_option" == 'all' ]]; then
  $unboundcontrol | grep -v thread | grep -v histogram | grep -v time. | sed 's/$/, /' | tr -d '\n'
elif [[ "$unbound_option" == 'total' ]]; then
  $unboundcontrol | grep -v thread | grep -v histogram | grep -v time. | sed 's/$/, /' | tr -d '\n' | tr ',' '\n' | grep 'total.' | tr '\n' ', '
elif [[ "$unbound_option" == 'num_query' ]]; then
  $unboundcontrol | grep -v thread | grep -v histogram | grep -v time. | sed 's/$/, /' | tr -d '\n' | tr ',' '\n' | grep 'num.query' | tr '\n' '; '
elif [[ "$unbound_option" == 'mem' ]]; then
  $unboundcontrol | grep -v thread | grep -v histogram | grep -v time. | sed 's/$/, /' | tr -d '\n' | tr ',' '\n' | grep 'mem.query' | tr '\n' ', '
elif [[ "$unbound_option" == 'answer_rcode' ]]; then
  $unboundcontrol | grep -v thread | grep -v histogram | grep -v time. | sed 's/$/, /' | tr -d '\n' | tr ',' '\n' | grep 'num.answer.rcode' | tr '\n' ', '
fi
