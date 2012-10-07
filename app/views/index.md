**Letters** is a little alphabetical library that makes sophisticated debugging easy &amp; fun.

For many of us, troubleshooting begins and ends with the `print` statement. Others recruit the debugger, too. (Maybe you use `print` statements to look at changes over time but the debugger to focus on a small bit of code.) These tools are good, but they are the lowest level of how we can debug in Ruby. Letters leverages `print`, the debugger, control transfer, computer beeps, and other side-effects for more well-rounded visibility into code and state.

To see all the methods that Letters has to offer, [check out the API](/api). (There are about 20 methods so far, for your browsing pleasure.)

If you want a thorough introduction, check out the screencast:

<a class="fancybox-media" rel="media-gallery" href="https://vimeo.com/50347457">
  <img src="/images/still.png" />
</a>

### Installation ###

If you're using RubyGems, install Letters with:

    #!plain
    gem install letters

By default, requiring `"letters"` monkey-patches `Object`. It goes without saying that if you're using Letters in an app that has environments, you probably only want to use it in development.

### Debugging with letters ###

With Letters installed, you have a suite of methods available wherever you want them in your code -- at the end of any expression, in the middle of any pipeline. Most of these methods will output some form of information, though there are more sophisticated ones that pass around control of the application.

Let's start with the `o` method as an example. It is one of the most familiar methods. Calling it prints the receiver to STDOUT and returns the receiver:

    #!ruby
    { foo: "bar" }.o 
    # => { foo: "bar" }
    # prints { foo: "bar" }

That's simple enough, but not really useful. Things get interesting when you're in a pipeline:

    #!ruby
    words.grep(/interesting/).
      map(&:downcase).
      group_by(&:length).
      values_at(5, 10).
      slice(0..2).
      join(", ")
    
If I want to know the state of your code after lines 3 and 5, all I have to do is add `.o` to each one:

    #!ruby
    words.grep(/interesting/).
      map(&:downcase).
      group_by(&:length).o.
      values_at(5, 10).
      slice(0..2).o.
      join(", ")

Because the `o` method (and nearly every Letters method) returns the original object, introducing it is only ever for side effects -- it won't change the output of your code.

This is significantly easier than breaking apart the pipeline using variable assignment or a hefty `tap` block.

The `o` method takes options, too, so you can add a prefix message to the output or choose another output format -- like [YAML]() or [pretty print]().

### The methods ###

<table>
  <tr>
    <th>Letter</th>
    <th>Command</th>
    <th>Options</th>
    <th>Description</th>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#a">a</a>
    </td>
    <td>
      Assert
    </td>
    <td>
      :message, 
      :error_class
    </td>
    <td>
      asserts in the context of its receiver or Letters::AssertionError
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#b">b</a>
    </td>
    <td>
      Beep
    </td>
    <td>
    </td>
    <td>
      causes your terminal to beep
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#c">c</a>
    </td>
    <td>
      Callstack
    </td>
    <td>
      :message 
    </td>
    <td>
      prints the current callstack
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#d">d</a>
    </td>
    <td>
      Debugger
    </td>
    <td>
      
    </td>
    <td>
      passes control to the debugger
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#d1/d2">d1/d2</a>
    </td>
    <td>
      Diff
    </td>
    <td>
      :message,
      :format,
      :stream
    </td>
    <td>
      prints a diff between first and second receivers
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#e">e</a>
    </td>
    <td>
      Empty
    </td>
    <td>
      :message
    </td>
    <td>
      raises a Letters::EmptyError if its receiver is empty
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#f">f</a>
    </td>
    <td>
      File
    </td>
    <td>
      :format, :name
    </td>
    <td>
      writes its receiver into a file in a given format
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#j">j</a>
    </td>
    <td>
      Jump
    </td>
    <td>
      (&block)
    </td>
    <td>
      executes its block in the context of its receiver
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#k">k</a>
    </td>
    <td>
      Kill
    </td>
    <td>
      :max
    </td>
    <td>
      raises Letters::KillError after a maximum number of calls
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#l">l</a>
    </td>
    <td>
      Logger
    </td>
    <td>
      :format, :level
    </td>
    <td>
      logs its receivers on the available logger instance
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#m">m</a>
    </td>
    <td>
      Mark as tainted
    </td>
    <td>
      (true|false)
    </td>
    <td>
      taints (or untaints) its receiver
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#n">n</a>
    </td>
    <td>
      Nil
    </td>
    <td>
      
    </td>
    <td>
      raises a Letters::NilError if its receiver is nil
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#o">o</a>
    </td>
    <td>
      Output
    </td>
    <td>
      :format,
      :stream
    </td>
    <td>
      prints its receiver to standard output
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#r">r</a>
    </td>
    <td>
      Ri
    </td>
    <td>
      (method name as symbol)
    </td>
    <td>
      prints RI documentation of its receiver class
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#s">s</a>
    </td>
    <td>
      Safety
    </td>
    <td>
      (level number)
    </td>
    <td>
      bumps the safety level (by one or as specified)
    </td>
  </tr>

  <tr>
    <td>
      <a href="http://lettersrb.com/api#t">t</a>
    </td>
    <td>
      Timestamp
    </td>
    <td>
      :time_format
    </td>
    <td>
      prints out the current timestamp
    </td>
  </tr>
</table>

### Configuration ###

Lastly, you can tune and tweak each Letters method to default to your own tastes. Want to name put files somewhere else? No problem. Don't like YAML? Default `f` to use Pretty Print instead! The world of defaults is your oyster.

    Letters.config do
      f :format => "pp", :name => "my-special-file"
    end

If you have a suggestion, let me know on the [mailing list](https://groups.google.com/forum/#!forum/lettersrb) or submit a [pull request on Github](http://github.com/davejacobs/letters). There is plenty more to do with this library -- for example, arbitrary object diffs, user-defined methods, renameable methods, and defaults configuration. This core is just the beginning.
