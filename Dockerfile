FROM golang:1.20 as build

WORKDIR /app
RUN go env -w GO111MODULE=auto 
RUN go get github.com/thedevsaddam/renderer/...
COPY main.go .
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build main.go


FROM alpine

LABEL name="Golang Application" \    
      maintainer="Ali Kahoot <kahoot.ali@outlook.com>" \
      summary="A Golang Sample application"  
WORKDIR /app
EXPOSE 8080 
COPY --from=build ./app/main ./
COPY ./tpl ./tpl
CMD ["./main"]