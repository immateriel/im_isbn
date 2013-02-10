## ISBN manipulation Ruby library

Helper class to convert and check ISBN validity

### Usage
Object initializer accept any EAN 10, EAN 13, ISBN 10 or ISBN 13 string with or without control key
```ruby
isbn=ISBN.new("9782814507159")
isbn=ISBN.new("978-2-8145-0715-9")
isbn=ISBN.new("978281450715")
isbn=ISBN.new("281450715X")
```
Creating object raise error when ISBN is invalid :
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
You can also quick check ISBN validity :
```ruby
ISBN.valid?("9782814507159")
=> true
ISBN.valid?("9782814507151")
=> false
```
You can convert to ISBN 13 string :
```ruby
isbn.to_isbn13_s
=> "978-2-8145-0715-9"
```
ISBN 13 array :
```ruby
isbn.to_isbn13_a
=> ["978", "2", "8145", "0715", "9"]
```
EAN 10 :
```ruby
isbn.to_ean10_s
=> "281450715X"
```
ISBN 10 string :
```ruby
isbn.to_isbn10_s
=> "2-8145-0715-X"
```

### License
Copyright (C) 2013 immatériel.fr

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
