Couple things:

1. Extracts JSON from a [Telegram](https://telegram.org) dump file, inserts it into an SQLite db.

  Dumps come from [telegram-cli](https://github.com/vysheng/tg) and [telegram-history=dump](https://github.com/tvdstaaij/telegram-history-dump).

2. Interacts with the SQLite db to provide a paginated, searchable interface to the dump. 
