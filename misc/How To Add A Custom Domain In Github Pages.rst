= link:http://hostingpages.club/how-to-add-a-custom-domain-in-github-pages/[How To Add A Custom Domain In Github Pages]

image:http://hostingpages.club/wp-content/uploads/2018/05/9Adding-Custom-Domain-696x279.png[]

Github Pages generated a URL. The URL was redgadget.github.io/test and then again a ‘/’. So as I said this, this really looks ugly so let’s say you have a custom URL that you want to use it on this page. So what do you have to do for that? So that is simple as well to all you need is a domain name. So I hope you have bought one from somewhere maybe namescheap or godaddy anywhere. I prefer godaddy because it’s cheap here.

== CNAME File

So I buy domains from them and so let’s get started adding custom URL to our website so let’s go to a repository. So what you have to do is, you have to add a CNAME file with your URL on it whichever you want your URL to be. So let’s check which URL is free. So in my domain list I don’t have many free, I’m going to jump right into truejewels which is free, “truejewel.in”. I haven’t configured anything on this, this is really a free one so truejewels.in, let’s see what it redirects to it’s saying web page is not available so let’s keep it and we are going to add a CNAME file so this is on the on the master branch actually so truejewels.in this is all so I CNAME file that should be a dot.

So make sure you don’t have any spaces or you don’t have any spelling mistake here so a CNAME file will not have an extension. So that you’ve to make sure and let’s commit to the master branch and for some reason I have to do the same thing on the gh-pages branch as well let’s add a CNAME file again .in true, just double checking. So now we are done with the CNAME, let’s see where it redirects to nothing. Now we have to you know configure the domain so that it will redirect to our Github Page. So you have to add a “A record” in your domain registrar. So truejewels.in I’m adding a record so there has to be an IP which redirects to Github Page. So you can Google out Github pages custom domain IP and click on the first link you get.

== Record

So these are the 2 IPs provided by Github to add an A record but I don’t think this IP will change if it changes then many, many websites will go down. So I’m going to add 600 seconds. So there are two AP so I’m going to add another A record I think it’s 154 that’s all the change it has. Let’s finish. Save this. That’s good. 154 and we have the CNAME in GH and master can close this off so this might take some time I will come back when it is done. I have waited for a while now let’s see if this has.

I have hosted it on trujewels use so it’s working and remember that you know how to add CNAM file both in master and even the **gh-pages branch**. So I have got the website i wanted to and you can create actually you know very, real good this is a simple upset actually you can create Blogs which look really good so here if I want to show this one, this has a URL this was my long actually this was a tech blog that I had a long back and I am not updating it this is a long time ago so this is a blog and this looks really nice so once you go to the URL and checkout If I want to open this one this is a simple one doesn’t have many things in it. You can also create blogs with Github Pages.
