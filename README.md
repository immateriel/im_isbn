## ISBN manipulation Ruby library

Helper class to convert and check ISBN validity

### Usage
ISBN class is encapsulated in ImIsbn module to avoid conflict.
You can
```ruby
include ImIsbn
```
to use ISBN as top level ISBN.

Object creation accept any EAN 10, EAN 13, ISBN 10 or ISBN 13 string
```ruby
isbn=ISBN.new("9782814507159")
isbn2=ISBN.new("978-3-492-96143-1")
```
Creation raise error when ISBN is invalid :
```ruby
isbn=ISBN.new("9782814507151")
raise ImIsbn::InvalidISBNControlKey: given ISBN control key is 1, must be 9
isbn=ISBN.new("9782814507AAA")
raise ImIsbn::InvalidISBNFormat: ImIsbn::InvalidISBNFormat
isbn=ISBN.new("97828145071534")
raise ImIsbn::InvalidISBNLength: given ISBN length is 14, must be 10 or 13
```
But you can try to correct the ISBN with :
```ruby
isbn=ISBN.corrected("9782814507151")
isbn.to_ean13_s
=> "9782814507159"
```
You can convert to ISBN 13 as string :
```ruby
isbn.to_isbn13_s
=> "978-3-492-96143-1"
```
Or array :
```ruby
isbn.to_isbn13_a
=> ["978", "3", "492", "96143", "1"]
```

### License
Copyright (C) 2013 immatériel.fr

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
