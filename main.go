package main

import (
	"fmt"
	"net/http"
	"github.com/thedevsaddam/renderer"
)

var rnd *renderer.Render

func init() {
	opts := renderer.Options{
		ParseGlobPattern: "./tpl/*.html",
	}

	rnd = renderer.New(opts)
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)
	mux.HandleFunc("/schedule", schedule)
	mux.HandleFunc("/health", health)
	fmt.Println("Server is Listening at 127.0.0.1:8080")
	http.ListenAndServe(":8080", mux)
}

func health(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "App is up and running")
}

func home(w http.ResponseWriter, r *http.Request) {
	rnd.HTML(w, http.StatusOK, "home", nil)
}

func schedule(w http.ResponseWriter, r *http.Request) {
	rnd.HTML(w, http.StatusOK, "schedule", nil)
}
