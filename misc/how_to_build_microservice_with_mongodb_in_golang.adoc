= How To Build Microservice With MongoDB In Golang 

These days Golang grows in popularity for writing RESTful microservices. Quite often these services utilize MongoDB as persistence storage. In this post we will build a simple book store microservice using both Go and MongoDB. We will connect to MongoDB with mgo driver and use curl to test the microservice.

== MongoDB 

MongoDB took market with storm by its simplicity, high availability and document orientation. The advantages of using documents over relational tables are:

 * Documents correspond to native data types in many programming languages.
 * Embedded documents and arrays reduce need for expensive joins.
 * Dynamic schema supports fluent polymorphism.

=== What is a document? 

A document is just a data structure composed of field and value pairs. The values of fields may include other documents, arrays, and arrays of documents. MongoDB documents are similar to JSON objects, and every document is stored as a record in MongoDB collection.

For example a book can be represented as the following document (json):

<code>
{
  "isbn":  "0134190440",
  "title":  "The Go Programming Language",
  "authors": ["Alan A. A. Donovan", "Brian W. Kernighan"],
  "price":  "$34.57"
}
</code>

=== Collection 

MongoDB stores similar documents in the same collection. E.g., we will store books in books collection. If you are from relational background, collection is similar to table. The difference is collection does not enforce any structure, although it implies that documents stored in the same collection will be alike.

=== Query 

If you want to fetch data from MongoDB, you have to query it first. Query is a MongoDB concept for a group of filter parameters that specify which data is requested. MongoDB uses json and bson (binary json) for writing queries. A query example to fetch a book with specified isbn could look like:

<code>
{
  "isbn": "1234567"
}
</code>

== MongoDB driver for Go 

mgo (pronounced as mango) is a reach MongoDB driver for Golang. Its API is very simple and follows standard Go idioms. We will see how it can help with building CRUD (create, read, update, delete) operations for microservice in a second, but first let’s get familiar with session management.

=== Session management 

Getting a session:

<code>
session, err := mgo.Dial("localhost")
</code>

Single session does not allow concurrent processing, therefore multiple sessions are usually required. The quickest way to get another session is to copy an existing one. Make sure that you close it after use:

<code>
anotherSession := session.Copy()
defer anotherSession.Close()
</code>

=== Searching document(s) 

mgo goes with bson package, which simplifies writing queries.

Fetching all documents in collection:

<code>
c := session.DB("store").C("books")

var books []Book
err := c.Find(bson.M{}).All(&books)
</code>

Searching a single document in collection:

<code>
c := session.DB("store").C("books")

isbn := ...
var book Book
err := c.Find(bson.M{"isbn": isbn}).One(&book)
</code>

=== Creating a new document 

<code>
c := session.DB("store").C("books")
err = c.Insert(book)
</code>

=== Updating a document 

<code>
c := session.DB("store").C("books")
err = c.Update(bson.M{"isbn": isbn}, &book)
</code>

=== Deleting a document 

<code>
c := session.DB("store").C("books")
err := c.Remove(bson.M{"isbn": isbn})
</code>

== Microservice with MongoDB in Go 

Below is a fully fledged example of book store microservice written in Go and backed by MongoDB. You can download the example from [[https://github.com/upitau/goinbigdata/tree/master/examples/mongorest|GitHub]].

> This service uses Goji for routing. Have a look at [[http://goinbigdata.com/restful-web-service-in-go-using-goji/|How to write RESTful services with Goji]] if you never used Goji before.

<code>
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"goji.io"
	"goji.io/pat"
	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
)

func ErrorWithJSON(w http.ResponseWriter, message string, code int) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(code)
	fmt.Fprintf(w, "{message: %q}", message)
}

func ResponseWithJSON(w http.ResponseWriter, json []byte, code int) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(code)
	w.Write(json)
}

type Book struct {
	ISBN  string  json:"isbn"
	Title  string  json:"title"
	Authors []string json:"authors"
	Price  string  json:"price"
}

func main() {
	session, err := mgo.Dial("localhost")
	if err != nil {
		panic(err)
	}
	defer session.Close()

	session.SetMode(mgo.Monotonic, true)
	ensureIndex(session)

	mux := goji.NewMux()
	mux.HandleFunc(pat.Get("/books"), allBooks(session))
	mux.HandleFunc(pat.Post("/books"), addBook(session))
	mux.HandleFunc(pat.Get("/books/:isbn"), bookByISBN(session))
	mux.HandleFunc(pat.Put("/books/:isbn"), updateBook(session))
	mux.HandleFunc(pat.Delete("/books/:isbn"), deleteBook(session))
	http.ListenAndServe("localhost:8080", mux)
}

func ensureIndex(s *mgo.Session) {
	session := s.Copy()
	defer session.Close()

	c := session.DB("store").C("books")

	index := mgo.Index{
		Key:    []string{"isbn"},
		Unique:   true,
		DropDups:  true,
		Background: true,
		Sparse:   true,
	}
	err := c.EnsureIndex(index)
	if err != nil {
		panic(err)
	}
}

func allBooks(s *mgo.Session) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		session := s.Copy()
		defer session.Close()

		c := session.DB("store").C("books")

		var books []Book
		err := c.Find(bson.M{}).All(&books)
		if err != nil {
			ErrorWithJSON(w, "Database error", http.StatusInternalServerError)
			log.Println("Failed get all books: ", err)
			return
		}

		respBody, err := json.MarshalIndent(books, "", " ")
		if err != nil {
			log.Fatal(err)
		}

		ResponseWithJSON(w, respBody, http.StatusOK)
	}
}

func addBook(s *mgo.Session) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		session := s.Copy()
		defer session.Close()

		var book Book
		decoder := json.NewDecoder(r.Body)
		err := decoder.Decode(&book)
		if err != nil {
			ErrorWithJSON(w, "Incorrect body", http.StatusBadRequest)
			return
		}

		c := session.DB("store").C("books")

		err = c.Insert(book)
		if err != nil {
			if mgo.IsDup(err) {
				ErrorWithJSON(w, "Book with this ISBN already exists", http.StatusBadRequest)
				return
			}

			ErrorWithJSON(w, "Database error", http.StatusInternalServerError)
			log.Println("Failed insert book: ", err)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Location", r.URL.Path+"/"+book.ISBN)
		w.WriteHeader(http.StatusCreated)
	}
}

func bookByISBN(s *mgo.Session) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		session := s.Copy()
		defer session.Close()

		isbn := pat.Param(r, "isbn")

		c := session.DB("store").C("books")

		var book Book
		err := c.Find(bson.M{"isbn": isbn}).One(&book)
		if err != nil {
			ErrorWithJSON(w, "Database error", http.StatusInternalServerError)
			log.Println("Failed find book: ", err)
			return
		}

		if book.ISBN == "" {
			ErrorWithJSON(w, "Book not found", http.StatusNotFound)
			return
		}

		respBody, err := json.MarshalIndent(book, "", " ")
		if err != nil {
			log.Fatal(err)
		}

		ResponseWithJSON(w, respBody, http.StatusOK)
	}
}

func updateBook(s *mgo.Session) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		session := s.Copy()
		defer session.Close()

		isbn := pat.Param(r, "isbn")

		var book Book
		decoder := json.NewDecoder(r.Body)
		err := decoder.Decode(&book)
		if err != nil {
			ErrorWithJSON(w, "Incorrect body", http.StatusBadRequest)
			return
		}

		c := session.DB("store").C("books")

		err = c.Update(bson.M{"isbn": isbn}, &book)
		if err != nil {
			switch err {
			default:
				ErrorWithJSON(w, "Database error", http.StatusInternalServerError)
				log.Println("Failed update book: ", err)
				return
			case mgo.ErrNotFound:
				ErrorWithJSON(w, "Book not found", http.StatusNotFound)
				return
			}
		}

		w.WriteHeader(http.StatusNoContent)
	}
}

func deleteBook(s *mgo.Session) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		session := s.Copy()
		defer session.Close()

		isbn := pat.Param(r, "isbn")

		c := session.DB("store").C("books")

		err := c.Remove(bson.M{"isbn": isbn})
		if err != nil {
			switch err {
			default:
				ErrorWithJSON(w, "Database error", http.StatusInternalServerError)
				log.Println("Failed delete book: ", err)
				return
			case mgo.ErrNotFound:
				ErrorWithJSON(w, "Book not found", http.StatusNotFound)
				return
			}
		}

		w.WriteHeader(http.StatusNoContent)
	}
}
</code>

== Testing with curl 

curl is an indispensable tool for building and testing RESTful microservices. Also curl commands often used in RESTful API documentation to provide examples of API invocation.

=== Adding a new book 

Sample request:

<code>
curl -X POST -H "Content-Type: application/json" -d @body.json http://localhost:8080/books

body.json:
{
  "isbn":  "0134190440",
  "title":  "The Go Programming Language",
  "authors": ["Alan A. A. Donovan", "Brian W. Kernighan"],
  "price":  "$34.57"
}
</code>

Sample response:

<code>
201 Created
</code>

=== Getting all books 

Sample request:

<code>
curl -H "Content-Type: application/json" http://localhost:8080/books
</code>

Sample response:

<code>
200 OK
[
 {
  "ISBN": "0134190440",
  "Title": "The Go Programming Language",
  "Authors": [
   "Alan A. A. Donovan",
   "Brian W. Kernighan"
  ],
  "Price": "$34.57"
 },
 {
  "ISBN": "0321774639",
  "Title": "Programming in Go: Creating Applications for the 21st Century (Developer's Library)",
  "Authors": [
   "Mark Summerfield"
  ],
  "Price": "$31.20"
 }
]
</code>

=== Getting a book 

Sample request:

<code>
curl -H "Content-Type: application/json" http://localhost:8080/books/0134190440
</code>

Sample response:

<code>
200 OK
{
 "ISBN": "0134190440",
 "Title": "The Go Programming Language",
 "Authors": [
  "Alan A. A. Donovan",
  "Brian W. Kernighan"
 ],
 "Price": "$34.57"
}
</code>

=== Updating a book 

Sample request:

<code>
curl -X PUT -H "Content-Type: application/json" -d @body.json http://localhost:8080/books/0134190440

body.json:
{
  "isbn":  "0134190440",
  "title":  "The Go Programming Language",
  "authors": ["Alan A. A. Donovan", "Brian W. Kernighan"],
  "price":  "$20.00"
}
</code>

Sample response:

<code>
204 No Content
</code>

=== Deleting a book 

Sample request:

<code>
curl -X DELETE -H "Content-Type: application/json" -d @body.json http://localhost:8080/books/0134190440
</code>

Sample response:

<code>
204 No Content
</code>

== The bottom line 

MongoDB is a very popular backend for writing microservices with Go. MongoDB driver for Go (mgo) is idiomatic and very easy to use. Don’t overlook curl if you are building, testing or documenting RESTful services.