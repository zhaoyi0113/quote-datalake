cd src 
rm -fr dist
mkdir dist
cp -fr datalake dist
# cp requirements.txt dist
# cd dist
# docker run -v $(pwd):/outputs -it --rm lambci/lambda:build-python3.6 pip install -r /outputs/requirements.txt -t /outputs/
cd ..
terraform apply -lock=true -auto-approve terraform