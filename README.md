# logtail_crystal

An implementation of the [logtail](http://manpages.ubuntu.com/manpages/trusty/man8/logtail2.8.html) command written in [Crystal Lang](https://crystal-lang.org)

## Behavior:

* Checks the byte size of a file and compares it to the offset. If the byte size has increased it prints out any new lines. 
* If the inode has changed it starts from the beginning
* If the file size is smaller than the offset, it starts from the beginning

## To build on Ubuntu 22:

* [Make sure you have Crystal 1.8.2 installed](https://crystal-lang.org/docs/installation/on_debian_and_ubuntu.html)
* Clone the repo: `git clone https://github.com/weirdbricks/logtail_crystal.git`
* Build: `crystal build --static --release --no-debug logtail.cr`
* Run: `./logtail`

## Optionally also move to /usr/local/bin

```
crystal build --static --release --no-debug logtail.cr
mv ./logtail /usr/local/bin/
```

## Usage instructions:

This command requires 1 argument which is the logfile you want to view. Subsequent runs of the command against the same logfile will only display any new lines. 

Optionally you can provide a second argument which is the offset file that you want to use. If you do not provide an offset filename, one will be created for you under `/tmp/#{filename}.offset`.

### Example 1 - Getting new lines from `/var/log/syslog`

```
./logtail /var/log/syslog
```

### Example 2 - Getting new lines from `/var/log/syslog` and creating an offset filename at `/dev/shm/buhahaha`

```
./logtail /var/log/syslog /dev/shm/buhahaha
```

### Example 3 - Getting new lines from `/var/log/syslog` without diagnostics:

```
./logtail /var/log/syslog /dev/shm/buhahaha 2>/dev/null
```
