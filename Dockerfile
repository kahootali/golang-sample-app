FROM golang:1.20 as build

WORKDIR /app
COPY go.mod go.sum .
RUN go mod download
COPY main.go .
COPY tpl ./tpl/
RUN CGO_ENABLED=0 go build main.go


FROM alpine

LABEL name="Golang Application" \    
      maintainer="Ali Kahoot <kahoot.ali@outlook.com>" \
      summary="A Golang Sample application"  
WORKDIR /app
EXPOSE 8080 
COPY --from=build /app/main ./
COPY --from=build /app/tpl ./tpl
CMD ["./main"]