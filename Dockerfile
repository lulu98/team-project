# simple image that should print something and sleep to stay up
# set base image
FROM alpine:latest
CMD echo "hello I am alive" | sleep 5m 
