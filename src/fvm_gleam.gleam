import common
import gleam/io
import lower
import parser
import runtime

pub fn main() {
  let e = parser.parse("(((\\x.\\y.x)(\\x.x))(3))(4)")
  io.println(common.pretty_expr(e))
  let ops = lower.lower(e, [])
  // ops
  // |> common.pretty_ops
  // |> io.println
  let result = runtime.run(ops, [], [], [])
  io.println(common.pretty_value(result))
}
