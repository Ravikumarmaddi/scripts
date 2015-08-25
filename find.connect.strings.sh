#!/bin/bash
aws rds describe-db-instances | grep Address | awk '{print $2}'
