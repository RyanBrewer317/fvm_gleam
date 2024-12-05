import common.{
  type Op, type Value, APP, CAP, ClosureVal, Int, IntVal, LAM, LIT, RET, VAR,
}

fn get(list: List(a), index: Int) -> a {
  case list, index {
    [], _ -> panic as "index out of bounds"
    [x, ..], 0 -> x
    [_, ..rest], n -> get(rest, n - 1)
  }
}

pub fn run(
  ops: List(Op),
  value_stack: List(Value),
  env_stack: List(Value),
  captures: List(Value),
) -> Value {
  // io.println(
  //   common.pretty_ops(ops)
  //   <> "\n| "
  //   <> common.pretty_values(value_stack)
  //   <> "\n| "
  //   <> common.pretty_values(env_stack)
  //   <> "\n| "
  //   <> common.pretty_closures(return_stack)
  //   <> "\n| "
  //   <> common.pretty_values(captures),
  // )
  // io.println("")
  case ops, value_stack {
    [], [] -> panic as "no final value"
    [], [x, ..] -> x
    [LIT(n), ..rest], vals ->
      run(rest, [IntVal(n), ..vals], env_stack, captures)
    [VAR(n), ..rest], vals ->
      run(rest, [get(env_stack, n), ..vals], env_stack, captures)
    [LAM(body), ..rest], vals ->
      run(rest, [ClosureVal(body, captures), ..vals], env_stack, [])
    [APP, ..rest], [arg, ClosureVal(body, env), ..vals] ->
      run(body, [ClosureVal(rest, vals), ..vals], [arg, ..env], captures)
    [APP, ..], _ -> panic as "application without enough stack values"
    [RET], [val, ClosureVal(body, env), ..vals] ->
      run(body, [val, ..vals], env, captures)
    [RET, ..], _ -> panic as "non-empty continuation at return"
    [CAP(n), ..rest], vals ->
      run(rest, vals, env_stack, [get(env_stack, n), ..captures])
  }
}
