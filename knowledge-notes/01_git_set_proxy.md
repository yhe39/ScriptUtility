# Git set proxy server configuration

When use git, you can set the git proxy server by:

```
git config --global http.proxy http://<HTTP_PROXY_SERVER>:<HTTP_PROXY_PORT>
git config --global https.proxy https://<HTTPS_PROXY_SERVER>:<HTTPS_PROXY_PORT>
```

In Intel, we use the following proxy for git:

```
git config --global http.proxy http://child-prc.intel.com:913
git config --global https.proxy http://child-prc.intel.com:913
```

Reference:
[Getting git to work with a proxy server](http://stackoverflow.com/questions/783811/getting-git-to-work-with-a-proxy-server)

