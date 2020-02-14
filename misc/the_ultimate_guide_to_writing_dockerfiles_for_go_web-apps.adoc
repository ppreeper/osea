#The Ultimate Guide to Writing Dockerfiles for Go Web-apps

You probably want to use Docker with Go, because:

 - Packaging as a container is required if you’re running it on Kubernetes (like me!)
 - You have to work with different versions of Go on the same machine.
 - You need exact, reproducible, shareable and deterministic environments for development as well as production.
 - You need a quick and easy way of building and deploying a final compiled binary.
 - You might want to get started quickly (anyone with Docker installed can start coding right away without setting up any other dependencies or GOPATH variables).

Well, you’ve come to the right place.

We’ll incrementally build a basic Dockerfile for Go, with **live reloading** and **package management**, and then extend the same to create a highly **optimized** production ready image with **~100x reduction** in size. If you use a CI/CD system, image size might not matter, but when docker push and docker pulls are involved, a leaner image will definitely help.

If you’d like to jump right ahead to the code, check out the GitHub repo:
[[https://github.com/shahidhk/go-docker|shahidhk/go-docker]]

{{https://cdn-images-1.medium.com/max/1600/1*B_mzJrbTJLsH6Fzb9wrjOQ.png|Dockerfile}}

##Contents

 - The Simplest One
 - Package Management & Layering
 - Live Reloading
 - Single Stage Production Build
 - Multi Stage Production Build
 - Bonus: Binary Compression using UPX
 - [Update] Dep instead of Glide
 - [Update] Scratch instead of Alpine

Let’s assume a simple directory structure. The application is called go-docker and the directory structure is as shown below. All source code is inside src directory and there is a Dockerfile at the same level. main.go defines a web-app listening on port 8080.

<code bash>
go-docker
├── Dockerfile
└── src
  └── main.go
</code>

###1. The Simplest One
Basic Dockerfile for running Go

<code bash>
FROM golang:1.8.5-jessie
= create a working directory
WORKDIR /go/src/app
= add source code
ADD src src
= run main.go
CMD ["go", "run", "src/main.go"]
</code>

We are using debian jessie here since some commands like go get require git etc. to be present. Also, all Debian packages are available in case we need them. For production version we’ll use a smaller image like alpine.

Build and run this image:

<code bash>
$ cd go-docker
$ docker build -t go-docker-dev .
$ docker run --rm -it -p 8080:8080 go-docker-dev
</code>

The app will be available at http://localhost:8080. Use Ctrl+C to quit.

But this doesn’t make much sense because we’ll have to build and run the docker image every time any change is made to the code.

A better version would be to mount the source code into a docker container so that the environment is contained and using a shell inside the container to stop and start go run as we wish.

<code bash>
$ cd go-docker
$ docker build -t go-docker-dev .
$ docker run --rm -it -p 8080:8080 -v $(pwd):/go/src/app \
       go-docker-dev bash

root@id:/go/src/app# go run src/main.go
</code>

These commands will give us a shell, where we can execute go run src/main.go and run the server. We can edit main.go from host machine and run the code again to see changes, as the the files are mounted directly into the container.

But, what about packages?

###2. Package Management & Layering

[[https://github.com/golang/go/wiki/PackageManagementTools|Package management in Go]] is still in an experimental stage. There are a couple of tools around, but my favorite is [[https://glide.sh/|Glide]]. We’ll install Glide inside the container and use it from within.

Create two files called glide.yaml and glide.lock inside go-docker directory:

<code bash>
$ cd go-docker
$ touch glide.yaml
$ touch glide.lock
</code>

Change the Dockerfile to the one below and build a new image.
Dockerfile with Glide

<code bash>
FROM golang:1.8.5-jessie
= install glide
RUN go get github.com/Masterminds/glide
= create a working directory
WORKDIR /go/src/app
= add glide.yaml and glide.lock
ADD glide.yaml glide.yaml
ADD glide.lock glide.lock
= install packages
RUN glide install
= add source code
ADD src src
= run main.go
CMD ["go", "run", "src/main.go"]
</code>

If you look closely, you can see that glide.yaml and glide.lock are being added separately (instead of doing a ADD . .), resulting in separate layers. By separating out package management to a separate layer, Docker will cache the layer and will only rebuild it if the corresponding files change, i.e. when a new package is added or an existing one is removed. Hence, glide install won’t be executed for every source code change.

Let’s install a package by getting into the container’s shell:

<code bash>
$ cd go-docker
$ docker build -t go-docker-dev .
$ docker run --rm -it -v $(pwd):/go/src/app go-docker-dev bash

root@id:/go/src/app# glide get github.com/golang/glog
</code>

Glide will install all packages into a vendor directory, which can be gitignore-d and dockerignore-d. It uses glide.lock to lock packages to specific versions. To (re-)install all packages mentioned in glide.yaml, execute:

<code bash>
$ cd go-docker
$ docker run --rm -it -p 8080:8080 -v $(pwd):/go/src/app \
       go-docker-dev bash

root@id:/go/src/app# glide install
</code>

The go-docker directory has grown a little bit now:

<code bash>
.
├── Dockerfile
├── glide.lock
├── glide.yaml
├── src
│  └── main.go
└── vendor/
</code>

Don’t forget to add vendor to .gitignore and .dockerignore.

###3. Live Reloading

[[https://github.com/codegangsta/gin|codegangsta/gin]] is my favorite among all the live-reloading tools. It is specifically built for Go web servers. We’ll install gin using go get:

Dockerfile with Gin

<code bash>
FROM golang:1.8.5-jessie
= install glide
RUN go get github.com/Masterminds/glide
= install gin
RUN go get github.com/codegangsta/gin
= create a working directory
WORKDIR /go/src/app
= add glide.yaml and glide.lock
ADD glide.yaml glide.yaml
ADD glide.lock glide.lock
= install packages
RUN glide install
= add source code
ADD src src
= run main.go
CMD ["go", "run", "src/main.go"]
</code>

We’ll build the image and run gin so that the code is rebuilt whenever there is any change inside src directory.

<code bash>
$ cd go-docker
$ docker build -t go-docker-dev .
$ docker run --rm -it -p 8080:8080 -v $(pwd):/go/src/app \
       go-docker-dev bash

root@id:/go/src/app# gin --path src --port 8080 run main.go
</code>

Note that the web-server should take a PORT environment variable to listen to since gin will set a random PORT variable and proxy connections to it.

All edits in src directory will trigger a rebuild and changes will be available live at http://localhost:8080.

Once we are done with development, we can build the binary and run it, instead of using the go run command. The binary can be built and served using the same image or we can make use of Docker multi-stage builds to build using a golang image and serve using a bare minimum linux container like alpine.

###4. Single Stage Production Build

Single stage: build and serve in the same container

<code bash>
FROM golang:1.8.5-jessie
= install glide
RUN go get github.com/Masterminds/glide
= create a working directory
WORKDIR /go/src/app
= add glide.yaml and glide.lock
ADD glide.yaml glide.yaml
ADD glide.lock glide.lock
= install packages
RUN glide install
= add source code
ADD src src
= build main.go
RUN go build src/main.go
= run the binary
CMD ["./main"]
</code>

Build and run the all-in-one image:

<code bash>
$ cd go-docker
$ docker build -t go-docker-prod .
$ docker run --rm -it -p 8080:8080 go-docker-prod
</code>

The image built will be ~750MB (depending on your source code), due to the underlying Debian layer. Let’s see how we can cut this down.

###5. Multi Stage Production Build

Multi stage builds lets you build programs in a full-fledged OS environment, but the final binary can be run from a very slim image which is only slightly larger than the binary itself.

Multi stage build using two different base images

<code bash>
FROM golang:1.8.5-jessie as builder
= install glide
RUN go get github.com/Masterminds/glide
= setup the working directory
WORKDIR /go/src/app
ADD glide.yaml glide.yaml
ADD glide.lock glide.lock
= install dependencies
RUN glide install
= add source code
ADD src src
= build the source
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main src/main.go

= use a minimal alpine image
FROM alpine:3.7
= add ca-certificates in case you need them
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
= set working directory
WORKDIR /root
= copy the binary from builder
COPY --from=builder /go/src/app/main .
= run the binary
CMD ["./main"]
</code>

The binary here is ~14MB and the docker image is ~18MB. Thanks to alpine awesomeness.

Want to cut down the binary size itself? Read ahead.

###6. Bonus: Binary Compression using UPX

At [[https://hasura.io/|Hasura]], we have been using [[https://upx.github.io/|UPX]] everywhere, our CLI tool binary which is ~50MB comes down to ~8MB after compression, making it easy to download. UPX can do extremely fast in-place decompression, without any extra tools since it injects the decompressor into the binary itself.

Multi stage build with binary compression

<code bash>
FROM golang:1.8.5-jessie as builder
= install xz
RUN apt-get update && apt-get install -y \
  xz-utils \
&& rm -rf /var/lib/apt/lists/*
= install UPX
ADD https://github.com/upx/upx/releases/download/v3.94/upx-3.94-amd64_linux.tar.xz /usr/local
RUN xz -d -c /usr/local/upx-3.94-amd64_linux.tar.xz | \
  tar -xOf - upx-3.94-amd64_linux/upx > /bin/upx && \
  chmod a+x /bin/upx
= install glide
RUN go get github.com/Masterminds/glide
= setup the working directory
WORKDIR /go/src/app
ADD glide.yaml glide.yaml
ADD glide.lock glide.lock
= install dependencies
RUN glide install
= add source code
ADD src src
= build the source
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main src/main.go
= strip and compress the binary
RUN strip --strip-unneeded main
RUN upx main

= use a minimal alpine image
FROM alpine:3.7
= add ca-certificates in case you need them
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
= set working directory
WORKDIR /root
= copy the binary from builder
COPY --from=builder /go/src/app/main .
= run the binary
CMD ["./main"]
</code>

The UPX compressed binary is ~3MB and the docker image is ~6MB.

**~100x reduction in size from where we started from.**

###7. Dep instead of Glide

[[https://github.com/golang/dep|dep]] is a prototype dependency management tool for Go. Glide is considered to be in a state of support rather than active feature development, in favour of dep. Executing dep init in a directory with glide.yaml and glide.lock will create Gopkg.toml and Gopkg.lock by reading the glide files.

Adding a new package using dep is similar to glide:

<code bash>
$ dep ensure -add github.com/sirupsen/logrus
</code>

glide install equivalent is dep ensure.

Dockerfile with dep instead of glide

<code bash>
FROM golang:1.8.5-jessie
= install dep
RUN go get github.com/golang/dep/cmd/dep
= create a working directory
WORKDIR /go/src/app
= add Gopkg.toml and Gopkg.lock
ADD Gopkg.toml Gopkg.toml
ADD Gopkg.lock Gopkg.lock
= install packages
= --vendor-only is used to restrict dep from scanning source code
= and finding dependencies
RUN dep ensure --vendor-only
= add source code
ADD src src
= run main.go
CMD ["go", "run", "src/main.go"]
</code>

###8. Scratch instead of Alpine

Alpine is useful when you have to quickly access the shell inside the container and do some debugging. For example, shell comes to the rescue while debugging DNS issues in a Kubernetes cluster. We can run ping/wget etc. Also, if your application makes API calls to external services over HTTPS, ca-certificates need to be present.

But, if you don’t need a shell or ca-certs, but just want to run the binary, you can use scratch as the base for the image in multi-stage build.

Multi-stage dockerfile with dep and scratch

<code bash>
FROM golang:1.8.5-jessie as builder
= install xz
RUN apt-get update && apt-get install -y \
  xz-utils \
&& rm -rf /var/lib/apt/lists/*
= install UPX
ADD https://github.com/upx/upx/releases/download/v3.94/upx-3.94-amd64_linux.tar.xz /usr/local
RUN xz -d -c /usr/local/upx-3.94-amd64_linux.tar.xz | \
  tar -xOf - upx-3.94-amd64_linux/upx > /bin/upx && \
  chmod a+x /bin/upx
= install dep
RUN go get github.com/golang/dep/cmd/dep
= create a working directory
WORKDIR /go/src/app
= add Gopkg.toml and Gopkg.lock
ADD Gopkg.toml Gopkg.toml
ADD Gopkg.lock Gopkg.lock
= install packages
RUN dep ensure --vendor-only
= add source code
ADD src src
= build the source
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main src/main.go
= strip and compress the binary
RUN strip --strip-unneeded main
RUN upx main

= use scratch (base for a docker image)
FROM scratch
= set working directory
WORKDIR /root
= copy the binary from builder
COPY --from=builder /go/src/app/main .
= run the binary
CMD ["./main"]
</code>

The resulting image is just 1.3 MB, compared to the 6MB apline image.

Any suggestions to improve the ideas above? Any other use-cases that you’d like to see? Do let me know in the comments or join the discussion on [[https://news.ycombinator.com/item?id=16308391|HackerNews]] & [[https://www.reddit.com/r/golang/comments/7vexdl/the_ultimate_guide_to_writing_dockerfiles_for_go/|Reddit]].
