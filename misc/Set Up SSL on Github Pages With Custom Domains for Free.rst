= link:https://hackernoon.com/set-up-ssl-on-github-pages-with-custom-domains-for-free-a576bdf51bc[Set Up SSL on Github Pages With Custom Domains for Free]

== Instructions:

. link:https://support.cloudflare.com/hc/en-us/articles/201720164-Sign-up-planning-guide[Sign up for Cloudflare] if you don’t already have an account.
. Add your website, and make sure all automatically generated records match those on your registrar’s website.
. If you already have a gh-pages website and are simply moving to https, you don’t need to do anything else.
. If not, and are trying to set up your site at apex, create an A record pointing to Github’s IP addresses, else a CNAME pointing to your-username.github.io.
. Make sure there’s a `CNAME` file at the root of your gh-pages repo with your domain name.
. Make sure there’s a `CNAME` file at the root of your gh-pages repo with your domain name.
. Go to your Domain Registrar’s website and change the Domain Name Servers to those Cloudflare provides you with.
. Finish Setting up your Domain on Cloudflare and go to the Domain Dashboard.
. Open the “Cloudflare Settings” for your domain, and change the SSL Setting to “Flexible SSL”.
. Redirect all visitors to HTTPS/SSL using https://support.cloudflare.com/hc/en-us/articles/200170536-How-do-I-redirect-all-visitors-to-HTTPS-SSL-[page rule].

image:https://cdn-images-1.medium.com/max/1600/0*Gye0cr_gE4hUL842.png[]

11. After a couple of hours, you’ll be able to open `yoursite.com` with `https`.

image:https://cdn-images-1.medium.com/max/2000/1*4ALm0XIU-qdxpNb-P8fSSg.png[]

== Drawback

It’s important to note that this setup is not fully secure — the connection between CloudFlare and GitHub pages is not secured. Since GitHub doesn’t have a SSL certificate for your domain, Full SSL is not possible with a custom domain. However, this setup does provide some protection your users (e.g. from the hacker on the same unsecured Wi-Fi network), and it allows your site to behave as if it has SSL (e.g. for web crawlers, APIs).
