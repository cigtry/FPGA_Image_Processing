@echo off
title %cd%

if exist sim_log (
    rd sim_log /s /q
    md sim_log
)

del /F /S /Q print_files\*

cd .\sim_log

modelsim -do ../run.do

