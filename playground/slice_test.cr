str = "\"awa\""
short = "\"s\""
empty = "\"\""
no_quote = "awawa"
half_quote = "\"half"
half_end_quote = "half\""
body = "\"\"\""

def slice_off_quote(s : String)
  head = s[0, 1]
  tail = s[s.size - 1, s.size]
  rst = s
  if head == "\""
    rst = rst[1, rst.size]
  end
  if tail == "\""
    rst = rst[0, rst.size - 1]
  end
  rst
end

puts slice_off_quote str
puts slice_off_quote short
puts slice_off_quote empty
puts slice_off_quote no_quote
puts slice_off_quote half_quote
puts slice_off_quote half_end_quote
puts slice_off_quote body