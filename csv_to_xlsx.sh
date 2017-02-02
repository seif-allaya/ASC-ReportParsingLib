#!/bin/bash
echo Converting file : $1
soffice --headless --convert-to xlsx:"Calc MS Excel 2007 XML" $1