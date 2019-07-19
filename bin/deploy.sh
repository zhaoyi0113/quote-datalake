cd crawler
rm -fr dist
pip install -r requirements.txt -t dist
cp src/*.py dist
cd dist
# zip -r deploy.zip *
cd ../..
terraform apply