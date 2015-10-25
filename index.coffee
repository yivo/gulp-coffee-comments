through = require 'through2'

module.exports = ->
  through.obj (file, enc, next) ->
    if not file.isNull() and file.isBuffer()

      contents = file.contents.toString('utf8')
        .replace /^([ \t]*# ?[^\n\r]*\n\r?){2,}([ \t]*else)?/gm, (match, _, block) ->

          content = match.replace(/[ \t]*else$/, '')

          begin   = content.match(/^[ \t]*/)[0]
          end     = content.match(/([ \t]*)# ?[^\n\r]*(\n\r?)?$/)[1]

          indent  = if block then '  $1' else '$1'
          ret     = content.replace(/^([ \t]*)#( ?[^\n\r]*)/gm, "#{indent} $2")

          ret     = "#{begin}###\n#{ret}#{end}###\n"
          ret

        .replace /^([ \t]*)#( ?[^\n\r]*)((?:\n\r?)+[ \t]*else)?/gm, (match, indent, content, block) ->
          return match if /^##/.test(content)
          ret = "#{indent}####{content.replace(/\s+$/, '')} ###"
          ret = "  #{ret}#{block}" if block
          ret

      file.contents = new Buffer(contents)

    @push(file)
    next()