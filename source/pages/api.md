Title: The API

The API
-------

Letters is a library dedicated to side effects. It is meant for debugging and patches core data structures with these methods. You can access these methods either by monkey-patching the core classes ...

    require "letters"

... or by including them a la carte:

    require "letters/patch"
    obj = Object.new
    Letters.patch! obj

### B (beep) ###

The `b` method causes your terminal to, well, beep. This one is mainly for fun but is also useful for coarse-grained time analysis. For example, you might leverage `b` to detect n + 1 SQL queries or other data manipulation that takes more than a few milliseconds.

    (1..1_000_000_000).b.map(&:succ).b.reduce(:+).b

If your terminal supports the audible bell, this query will beep every time the pipeline reaches a `b` and will pass through the results to the next method.

### C (callstack) ###

The `c` method prints the current callstack.

    def inner
      # Print the callstack
      rand.c * 10
    end

    def outer(multiplier)
      inner * multiplier
    end

    outer 4

In IRB, this prints:

    #!plain
    <main>:1:in `inner_method'
    <main>:5:in `outer_method'
    (irb):3:in `irb_binding' 
      <rubydir>/irb/workspace.rb:80: in `eval'

Again, this does not interrupt execution of your code -- it just lets you know where you are.

### D (debugger) ###

We all know and love the debugger, but normal debugger calls are imperative. It can be a pain to break apart code to fit in a debugger. Instead, consider invoking `d` at the end of any expression:

    Network.fetch_data.d.all? do |str|
      str.length > 25 
    end

The `d` method will be even more powerful when combined with other constructs like transmitters and receivers *(not yet implemented)*.

### D1/D2 pairs (object diff) ###

The `d1/d2` method pair brings [`diff`](http://man.cx/diff) to your Ruby environment. Instead of printing a line-by-line diff, though, this diff prints out a hash. How does this method pair work? All you need to do is mark the first object for comparison with `d1` and then call `d2` on the second object. By default, `d1` and `d2` work on arrays, hashes, and any object that defines a sane minus method (`-`) for comparing itself with like objects.

    [1, 2, 3].d1.map {|x| x ** 2 }.d2

Calling the expression will print the following in the [awesome print]() format:

    { 
      removed: [2, 3],
      added: [4, 9]
    }

`d` will also give an `updated` list for hashes.

### E (empty check) ###

The `e` method is meant to quickly check if any expression is empty. One of two methods that does not always return its receiver, `e` will raise a `Letters::EmptyError` if its receiver is empty. (The other such method is `n`, used for nil checking.) Of course, if it is not empty, the receiver is passed through.

    [].e
    # => raises Letters::EmptyError

    [1, 2, 3].e
    # => [1, 2, 3]

### F (write to file) ###

Sometimes, you want to be able to manipulate the results of a method call in your favorite text editor. Maybe you want to use sophisticated Unix tools to a unnecessarily gigantic object. You could always stop to break apart your code, create a file block, remember the file flag options, and maybe break downstream code in the process. Or you could tag your object with `f`:

    JSON.parse(body).f.values_at(:name, :title)

By default, this will write to a file called "log" in your current directory. It will dump the object out in YAML format. To change either of those settings, add parameters to `f`:

    object.f(:format => "json")
    object.f(:name => "file.txt")

#### Options ####

    :format => "yaml"
    :name => "log"

See "Formats" below for all available formats.

### J (jump into object) ###

The `j` method gives you a block in the context of the object it's called on. You can call any of the object's methods (in addition to `puts`, etc., for finer-grained debugging) without naming a receiver. Note that if you mutate the object, it will be mutated on the other side of the method.

    [1, 2, 3].j { puts count unless empty? }.reduce(:+)
    # => 6

This expression will print 3 and return 6.

### L (logger) ###

The `l` method assumes you have an instance of a Ruby logger returned by the method `logger`. This will be the case in any standard Rails or Sinatra app. You can also set one up using the [standard Ruby logger](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/logger/rdoc/Logger.html) or [Log4r](http://log4r.rubyforge.org/). 

#### Options ####

    :level => "info"
    :format => "yaml"

- *M* - Mark with message to be printed when object is garbage-collected\*
- *N* - Nil check -- raise error if receiver is nil
- *O* - List all instantiated objects\*
- *P* - Print to STDOUT (format can be default or specified)
- *Q* - 
- *R* - RI documentation for class
- *S* - Bump [safety level]()
- *T* - [Taint object]()
- *U* - Untaint object
- *V* - 
- *W* - 
- *X* - Transmit control to nearest intercepter, passing object\*
- *Y* - 
- *Z* - 

Formats
-------

The following formats are supported. They can be specified by passing `format: "format"` to appropriate methods. 

- YAML (`format: "yaml"`)
- JSON (`format: "json"`)
- XML (`format: "xml"`)
- Ruby Pretty Print (`format: "pp"`)
- Ruby [Awesome print]() (`format: "ap"`)

<hr />

\*Requiring `"letters"` on its own will add the alphabet methods to these core classes: `Hash`, `Array`, `String`, `nil`. If you don't want to patch them with such small method names, you can explicitly require `"letters/core_ext"` instead. `Letters::CoreExt` will be available for you to `include` in any instance or class you'd like.
