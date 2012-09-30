The API
-------

If you think about it, Letters is a library dedicated to side effects. It wants to stay out of your logic, to keep clear of application state. The purpose of Letters is to give you a window into an otherwise closed pipeline or code path, and to make that window as easy as possible to set up and tear down.

Letters shouldn't stay in your code base, so it takes the liberty of patching `Object`. This happens when you enter:

    require "letters"

For Rails apps, there may be conflicts with the `t` method in `ActionPack`. To handle that conflict, do not require all of Letters. Instead:

    require "letters/patch/rails"

If you don't want to patch everything, you can patch classes and objects a la carte:

    require "letters/patch"
    Letters.patch! Hash
    obj = Object.new
    Letters.patch! obj

### A (assert) ###

The `a` method stands apart from most other Letters methods. Why? Because it does not always return its receiver. `a` is used to craft assertions, and if an assertion fails, it raises an error. Two special cases of the `a` method are `e` and `n`, which assert that their receivers are not empty or nil (respectively). 

The `a` method jumps into the context of its receiver, so all assertions can be made without explicitly referring to the object:

    [1, 2, 3].a { count == 3 }
    # => [1, 2, 3]

Notice that you didn't have to pass a block argument in.

Assertions will fail if the result of the block is not truthy (as defined by Ruby). That is, false or nil blocks will raise a `Letters::AssertionError`.

    [1, 2, 3].a { count > 3 }
    # Raises Letters::AssertionError

    [1, 2, 3].a { nil }
    # Raises Letters::AssertionError

The `a` method can take a message that will be printed every time the assertion is made. It can also take an `Exception` class to be raised if the assertion fails.

#### Options ####

    :message => nil
    :error_class => Letters::AssertionError

### B (beep) ###

The `b` method causes your terminal to, well, beep. This one is mainly for fun but is also useful for coarse-grained time analysis. For example, you might leverage `b` to detect n + 1 SQL queries or other data manipulation that takes more than a few milliseconds.

    (1..100_000_000).b.map(&:succ).b.reduce(:+).b
    # => 5000000150000000

If your terminal supports the audible bell, this query will beep every time the pipeline reaches a `b` and will pass through the results to the next method.

For more fine-grained time analysis, see the timestamp method, `t`.

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

#### Options ####

    :message => nil

### D (debugger) ###

We all know and love the debugger, but normal debugger calls are imperative. It can be a pain to break apart code to fit in a debugger. Instead, consider invoking `d` at the end of any expression:

    Network.fetch_data.d.all? do |str|
      str.length > 25 
    end

The `d` method will be even more powerful when combined with other constructs like transmitters and receivers *(not yet implemented)*.

### D1/D2 pairs (object diff) ###

The `d1/d2` method pair brings [`diff`](http://man.cx/diff) to your Ruby environment. Instead of printing a line-by-line diff, though, this diff prints out a hash. How does this method pair work? All you need to do is mark the first object for comparison with `d1` and then call `d2` on the second object. By default, `d1` and `d2` work on arrays, hashes, and any object that defines a sane minus method (`-`) for comparing itself with like objects.

    [1, 2, 3].d1.map {|x| x ** 2 }.d2

Calling the expression will print the following in the [Awesome Print](http://www.rubyinside.com/awesome_print-a-new-pretty-printer-for-your-ruby-objects-3208.html) format:

    { 
      removed: [2, 3],
      added: [4, 9]
    }

For hashes, each value in the diff is also a hash (and there is an `updated` key):

    { a: "foo", b: "bar", c: "baz" }.d1.select do |k, v|
      k =~ /[ab]/
    end.merge(:a => "new-foo", d: "bat").d2
    # => { a: "new-foo", b: "bar" }
    # Prints:
    # {
    #   added: { d: "bat" }
    #   removed: { c: "baz" }
    #   updated: { a: "new-foo" }
    # }

#### Options for d2 ####

    :message => nil
    :format => "ap"
    :stream => $stdout

### E (empty check) ###

The `e` method is meant to quickly check if an expression is empty. One of two methods that does not always return its receiver, `e` will raise a `Letters::EmptyError` if its receiver is empty. (The other such method is `n`, used for nil checking.) Of course, if it is not empty, the receiver is passed through.

    [].e
    # => raises Letters::EmptyError

    [1, 2, 3].e
    # => [1, 2, 3]

#### Options ####

    :message => nil

### F (write to file) ###

Sometimes, you want to be able to manipulate the results of a method call in your favorite text editor. Maybe you want to use sophisticated Unix tools to pick apart an unnecessarily gigantic object. You could always stop to break open your code, create a file block, remember the file flag options, and accidentally change downstream code in the process. Or you could tag your object with `f`:

    JSON.parse(body).f.values_at(:name, :title)

By default, this will write to a file called "log" in your current directory. It will dump the object out in YAML format. To change either of those settings, add parameters to `f`:

    object.f(:format => "json")
    object.f(:name => "file.txt")

#### Options ####

    :format => "yaml"
    :name => "log"

See "Formats" below for all available formats.

### J (jump into object) ###

The `j` method gives you a block in the context of the object it's called on. You can call any of the object's methods (in addition to `puts`, etc., for finer-grained debugging) without naming a receiver. (You could be explicit and use `self`. But what does this look like, Python?) Note that if you mutate the object, it will be mutated on the other side of the method.

    [1, 2, 3].j { puts length unless empty? }.reduce(:+)
    # => 6

This expression will print 3 and return 6.

### L (logger) ###

The `l` method assumes you have an instance of a Ruby logger returned by the method `logger`. This will be the case in any standard Rails or Sinatra app. You can also set one up using the [standard Ruby logger](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/logger/rdoc/Logger.html) or [Log4r](http://log4r.rubyforge.org/). 

#### Options ####

    :format => "yaml"
    :level => "info"

### M (mark as tainted, untainted) ###

While not used every day, tainting and untainting objects gives us more control over what we allow through our code. In Ruby, tainted objects (mostly) represent user input and derived values. They can be tainted and untainted at will at the lower safety levels. 

`m` can taint or untaint its receiver object. Without an argument, `m` will taint its receiver. With a falsy argument, `m` will untaint its receiver.

    [1, 2, 3].m.p { tainted? }
    # => [1, 2, 3]
    # Prints "true"

    [1, 2, 3].m(true).m(false).p { tainted? }
    # => [1, 2, 3]
    # Prints "false"

### N (nil check) ###

The `n` method is meant to quickly check if an expression is nil. One of two methods that does not always return its receiver, `n` will raise a `Letters::NilError` if its receiver is nil. (The other such method is `e`, used to check for empty objects.) Of course, if it is not nil, the receiver is passed through.

    nil.n
    # => raises Letters::NilError

    [1, 2, 3].n
    # => [1, 2, 3]

### P (print to STDOUT) ###

P is the `print` statement. (Well, actually, `puts`.) You know how to use this one.

    [1, 2, 3].p
    # => [1, 2, 3]

By default, this will print the object to STDOUT in [Awesome Print](http://www.rubyinside.com/awesome_print-a-new-pretty-printer-for-your-ruby-objects-3208.html) format. To change the format, add a parameter to `p`:

    [1, 2, 3].p(:format => "yaml")

If a block is passed in, it will be executed "inside" of the object (like the `j` method), and the final result of the block will be printed out instead.

The `j` example looked something like this:

    [1, 2, 3].j { puts length unless empty? }.reduce(:+)

With `p`, we could rewrite the expression as ...

    [1, 2, 3].p { length unless empty? }.reduce(:+)
    
... for the same effect.

#### Options ####

    :format => "ap"
    :stream => $stdout

### R (RI) ###

You've probably forgotten about RI, haven't you? It's that tool that comes with Ruby and is meant to make offline documentation easy.

Because there are plenty of resources on the Internet, namely [RubyDoc](http://ruby-doc.org), people tend to disable RDoc generation. But context-switching from the terminal/keyboard to the browser/mouse can be disruptive. So Letters gives you the power to explore Ruby's documentation from the comfort of your own terminal. 

To check out the documentation for an object's class, simply use the `r` method:

    [1, 2, 3].r
    # => [1, 2, 3]

When you call this method, you will get the following in STDOUT:

    #!plain
    = Array < Object

    ---------------------------------------------------
    = Includes:
    Enumerable (from ruby site)

    (from ruby site)
    ---------------------------------------------------
    Arrays are ordered, integer-indexed collections of
    any object. Array indexing starts at 0, as in C or
    Java. A negative index is assumed to be relative
    to the end of the array---that is, an index of -1
    indicates the last element of the array, -2 is the
    next to last element in the array, and so on.

    ---------------------------------------------------
    = Class methods:

      [], new, try_convert

    ... etc., etc. ...

Not interested in learning what an array is? Pass in a method name:

    [1, 2, 3].r(:grep)
    # => [1, 2, 3]

Now you get more focused information:

    #!plain
    = Array#grep

    (from ruby site)
    === Implementation from Enumerable
    --------------------------------------------------
      enum.grep(pattern)                   -> array
      enum.grep(pattern) {| obj | block }  -> array

    --------------------------------------------------

    Returns an array of every element in enum for
    which Pattern === element. If the optional block
    is supplied, each matching element is passed to
    it, and the block's result is stored in the output
    array.

      (1..100).grep 38..44   #=> [38, 39, 40, 
                                  41, 42, 43, 44]
      c = IO.constants
      c.grep(/SEEK/)         #=> [:SEEK_SET,
                                  :SEEK_CUR,
                                  :SEEK_END]

      res = c.grep(/SEEK/) {|v| IO.const_get(v) }
      res                    #=> [0, 1, 2]
    
If you're using RVM and need to generate your RDoc again, type the following in and go grab a coffee:

    #!plain
    rvm docs generate all

### S (bump safety level) ###

Ruby's safety level is sort of like the US national security level. With an escalated safety level, it's harder to change things that should be easy, and nothing gets done. Really, the only difference between Ruby's security level and the United States' is that Ruby's does not default to Threat Level Orange.

Though not often used, the safety level can be an englightening tool for debugging, both to gauge the attack vectors your code is vulnerable to, and to see how much user input you're relying on.

For more information on the Ruby safety level, see the online [Pickaxe documentation](http://ruby-doc.org/docs/ProgrammingRuby/html/taint.html#S1).

The `s` method will bump the safety level up by one. If supplied a specific number (0 - 4), it will try to change the safety level to that number. If the safety level cannot be changed, this method will raise an error.

The `s` method is most interesting when combined with tainted objects.

### T (timestamp) ###

The `t` method will print out the current timestamp. This can be useful for identifying bottlenecks in code more precisely than with `b` but without the complexity of a profiler.

    (1..100_000_000).t.map(&:succ).t.reduce(:+).t
    # => 5000000150000000

This call prints something like:

    #!plain
    09/24/2012 13:35:15.282
    09/24/2012 13:35:33.016
    09/24/2012 13:35:43.172

#### Options ####

The `:time_format` option allows you to print timestamps in any time format [you've registered with ActiveSupport](http://ofps.oreilly.com/titles/9780596521424/active-support.html#id390940856542).

    :time_format => "millis"

Formats
-------

The following formats are supported. They can be specified by passing `format: "format"` to appropriate methods. 

- Ruby Pretty Print (`format: "pp"`)
- Ruby [Awesome Print](http://www.rubyinside.com/awesome_print-a-new-pretty-printer-for-your-ruby-objects-3208.html) (`format: "ap"`)
- YAML (`format: "yaml"`)
- JSON (`format: "json"`)
- XML (`format: "xml"`)

----------------------

\*Requiring `"letters"` on its own will add the alphabet methods to `Object`.

To patch just the core classes, `require "letters/patch/core"`.

If you don't want to patch them with such small method names, you can explicitly require `"letters/patch"` instead. `Letters.patch!` will be available to patch any class or instance you like.

If you do patch an instance, the letter methods will only be available on that instance and not on any derivative instances. For example, this will not work:

    require "letters/patch"
    arr = [1, 2, 3]
    Letters.patch! arr

    # Does not work
    arr.p.map {|x| x ** 2 }.p

The second call to `p` will fail because the derivative array (result of the `map` call) has not been patched. Of course, mutating the original array is one way to solve this problem, albeit error-prone:

    # Works, but patching Array is probably better
    arr.p.map! {|x| x ** 2 }.p
