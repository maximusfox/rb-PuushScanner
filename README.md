# Puush Scanner

This script downloads images from the [puush](https://puush.me/) service. It takes a range of image IDs and downloads any images that are available.

## Install

```
git clone https://github.com/maximusfox/rb-PuushScanner.git
sudo gem install httpclient

cd rb-PuushScanner
chmod +x main.rb
```

## Usage

./puush_downloader.rb [options]

Available options:

* `-t, --threads COUNT`: Number of threads to use (default: 4)
* `-f, --first-id ID`: First ID to check (default: mHHi0)
* `-l, --last-id ID`: Last ID to check (default: mHHi9)
* `-c, --command TEMPLATE`: Command template to execute (default: 'echo ""; wget -nv %<url>s -O %<id>s.%<extension>s')

## Examples

Download images with IDs between mHHi50 and mHHi70 using 8 threads:

```bash
./main.rb -t 8 -f mHHi50 -l mHHi70
```
