#Golang HTTP server for pro

How to start a new web project with Go, using Routing, Middleware and Let’s Encrypt certification.

Golang have a great http server package: net/http As always, it’s simple and very powerful. Define the function that handle a route, and let’s listen to port 80.

<code go>
package main

import (
	"io"
	"net/http"
)

func main() {
	http.HandleFunc("/", helloWorldHandler)
	http.ListenAndServe(":80", nil)
}

func helloWorldHandler(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "Hello world!")
}
</code>

Nice, but let’s use a more powerfull router like the Gorilla package: gorilla/mux [[http://www.gorillatoolkit.org/pkg/mux|http://www.gorillatoolkit.org/pkg/mux]]

It implements a request router and a dispatcher. It allows you to create routes with named parameters, restricted on http verb and host/domain management.

Updating the previous exemple with this package allow us to manage easily many routes with simples configurations:

<code go>
func main() {
  r := mux.NewRouter()
  r.HandleFunc("/products/{key}", ProductHandler)
  r.HandleFunc("/articles/{category}/", ArticlesCategoryHandler)
  r.HandleFunc("/articles/{category}/{id:[0-9]+}", ArticleHandler)
  http.Handle("/", r)
}
</code>

##Use alice to manage our middleware

[[https://en.wikipedia.org/wiki/Middleware|Middleware pattern]] is very common if you use the webserver package. If you don’t have seen it yet, you should watch this video from Mat Ryer at the Golang UK Conference 2015 about the power of middleware. ([[https://medium.com/@matryer/writing-middleware-in-golang-and-how-go-makes-it-so-much-fun-4375c1246e81|Full blog post here]])

And another great article about the middleware patterns [[http://www.alexedwards.net/blog/making-and-using-middleware|http://www.alexedwards.net/blog/making-and-using-middleware]]

As described by it author ([[https://github.com/justinas/alice|Github]]):

  Alice provides a convenient way to chain your HTTP middleware functions and the app handler.

In short, it transforms

<code go>
Middleware1(Middleware2(Middleware3(App)))
</code>

to

<code go>
alice.New(Middleware1, Middleware2, Middleware3).Then(App)
</code>

Here’s our first exemple, updated with Alice’s usage:

<code go>
func main() {
  errorChain := alice.New(loggerHandler, recoverHandler)

r := mux.NewRouter()
  r.HandleFunc("/products/{key}", ProductHandler)
  r.HandleFunc("/articles/{category}/", ArticlesCategoryHandler)
  r.HandleFunc("/articles/{category}/{id:[0-9]+}", ArticleHandler)
  http.Handle("/", errorChain.then(r))
}
</code>

You can chain many handler, but here are the two described:

<code go>
func loggerHandler(h http.Handler) http.Handler {

  return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    start := time.Now()
    h.ServeHTTP(w, r)
    log.Printf("<< %s %s %v", r.Method, r.URL.Path, time.Since(start))
  })
}
</code>

The loggerHandler, and the recoverHandler:

<code go>
func recoverHandler(next http.Handler) http.Handler {
  fn := func(w http.ResponseWriter, r *http.Request) {
    defer func() {
      if err := recover(); err != nil {
        log.Printf("panic: %+v", err)
        http.Error(w, http.StatusText(500), 500)
      }
    }()

next.ServeHTTP(w, r)
  }

return http.HandlerFunc(fn)
}
</code>

At this point, we have a HTTP server, with a powerful routing package. You can also manage middleware with ease, to extend quickly the functionalities of your application.

##HTTP server is nice, HTTPS server is better!

Easy and fast way to create a secure HTTP server, it to use Let’s Encrypt service. Let’s Encrypt uses the [[https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment|ACME protocol]] to verify that you control a given domain name and to issue you a certificate. It’s called a certification, and yes, there’s a Auto-Certification package: [[https://godoc.org/golang.org/x/crypto/acme/autocert|acme/autocert]]

<code go>
m := autocert.Manager{
  Prompt:   autocert.AcceptTOS,
  HostPolicy: autocert.HostWhitelist("www.checknu.de"),
  Cache:   autocert.DirCache("/home/letsencrypt/"),
}
</code>

Create the http.server using tls:

<code go>
server := &http.Server{
  Addr: ":443",
  TLSConfig: &tls.Config{
    GetCertificate: m.GetCertificate,
  },
}

err := server.ListenAndServeTLS("", "") if err != nil {     log.Fatal("ListenAndServe: ", err) }
</code>

{{https://cdn-images-1.medium.com/max/800/1*Wn9uFSeup0blHnxweTFdoQ.png|And now it’s done!}}

You can find this HTTP server here: {{https://github.com/ScullWM/go-bootstrap|ScullWM/go-bootstrap}}
