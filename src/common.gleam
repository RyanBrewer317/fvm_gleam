import gleam/list
import gleam/string

pub type Expr {
  Int(Int)
  Ident(Int)
  Lam(Expr)
  App(Expr, Expr)
}

pub fn pretty_expr(expr: Expr) -> String {
  case expr {
    Int(n) -> string.inspect(n)
    Ident(n) -> "x" <> string.inspect(n)
    Lam(body) -> "λ. " <> pretty_expr(body)
    App(f, x) -> "(" <> pretty_expr(f) <> ")(" <> pretty_expr(x) <> ")"
  }
}

pub type Value {
  IntVal(Int)
  ClosureVal(body: List(Op), env: List(Value))
}

pub fn pretty_value(value: Value) -> String {
  case value {
    IntVal(n) -> string.inspect(n)
    ClosureVal(body, env) ->
      "(" <> pretty_ops(body) <> ", " <> pretty_values(env) <> ")"
  }
}

pub fn pretty_values(values: List(Value)) -> String {
  case values {
    [] -> "[]"
    _ -> list.map(values, pretty_value) |> string.join(", ")
  }
}

pub type Op {
  LIT(Int)
  VAR(Int)
  LAM(List(Op))
  APP
  RET
  CAP(Int)
  // OWN(Int): the same as `VAR(Int)` but it (unsafely) doesn't clone, 
  // so in this implementation there's no difference
}

pub fn pretty_op(op: Op) -> String {
  case op {
    LIT(n) -> "LIT(" <> string.inspect(n) <> ")"
    VAR(n) -> "VAR(" <> string.inspect(n) <> ")"
    LAM(ops) -> "LAM(" <> pretty_ops(ops) <> ")"
    APP -> "APP"
    RET -> "RET"
    CAP(n) -> "CAP(" <> string.inspect(n) <> ")"
  }
}

pub fn pretty_ops(ops: List(Op)) -> String {
  case ops {
    [] -> "[]"
    _ -> list.map(ops, pretty_op) |> string.join(" ")
  }
}
