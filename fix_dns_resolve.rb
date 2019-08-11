# There's a strange bug in the native ruby resolve library, only reproducible on some instances on GCE, 
# which essentially disables DNS address resolution when using ndots > 1 with a search list, each element
# in the list is somehow queried twice causing the address to never be resolved on its own,
# this solves the issue by commenting out the search list, but full DNS names must be then used through the app
c = File.read('/etc/resolv.conf')
c.sub!('search', '#search')
File.write('/etc/resolv.conf', c)