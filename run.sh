#!/bin/bash
# Utility for running the different apps since dub is dumb

APP=$1

rdmd -g -unittest source/$APP
