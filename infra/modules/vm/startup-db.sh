#!/bin/bash
set -e
# Install PostgreSQL
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql
# Create database + user
sudo -u postgres psql <<SQL
CREATE USER shortener WITH PASSWORD 'ChangeMe123';
CREATE DATABASE yinklydb OWNER shortener;
SQL
