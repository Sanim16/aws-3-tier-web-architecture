#!/bin/bash
sudo yum install mysql -y
mysql -h ${db_address} -u ${admin_user} -p${admin_password}  << eof
CREATE DATABASE webappdb;
USE webappdb;    
CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL AUTO_INCREMENT, amount DECIMAL(10,2), description VARCHAR(100), PRIMARY KEY(id));    
INSERT INTO transactions (amount,description) VALUES ('400','groceries');
eof
