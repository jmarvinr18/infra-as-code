FROM python:3.10

WORKDIR /app

ARG AWS_KEY=""
ARG AWS_SECRET_KEY=""
ARG AWS_REGION=""

COPY requirements.txt .

RUN pip install -r ./requirements.txt

RUN aws configure set aws_access_key_id $AWS_KEY \
&& aws configure set aws_secret_access_key $AWS_SECRET_KEY \
&& aws configure set default.region $AWS_REGION

COPY . .

EXPOSE 5000

CMD ["flask", "run", "--host", "0.0.0.0"]