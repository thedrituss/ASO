#!/bin/bash

MEMORIA_LIBRE=$(vmstat 2 4 | awk '{print $4}')

echo "La memoria libre es: $MEMORIA_LIBRE"
