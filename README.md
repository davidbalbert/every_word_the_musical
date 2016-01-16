# Every Word the Musical!

A Twitter bot to generate musical theater ideas.

## Requirements

- A new-ish Ruby
- SSH and a keypair configured on AWS

## Running it locally

To setup, do the following:

```
$ bundle
$ cp .env.example .env
```

Then edit `.env` and fill in your Twitter credentials.

Every time you run `ruby every_word.rb` it will tweet the next word.

## Deploying to EC2

Boot up a t2.nano instance running Ubuntu 14.04 LTS, clone this repository, and run the following:

```
$ cp .env.production.example .env
```

Edit your `.env` file and then run `setup.sh`. This will install all the requirements, set up a crontab, and make sure your server automatically installs security updates.

In production, Every Word the Musical! will log to the local syslog daemon.

## License

Copyright 2016 David Albert. Released under the terms of the GNU GPLv3 or later. See COPYING for more info.
