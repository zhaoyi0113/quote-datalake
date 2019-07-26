rm -fr build
mkdir -p build/python
cp src/requirements.txt build/python
cd build/python
docker run -v $(pwd):/outputs -it --rm lambci/lambda:build-python3.6 pip install -r /outputs/requirements.txt -t /outputs/
cd ..
zip -r lambda_layer.zip *
aws s3 cp lambda_layer.zip s3://${s3_bucket}/crawler/