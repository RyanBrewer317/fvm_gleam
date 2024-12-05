import common.{
  type Expr, type Op, APP, App, CAP, Ident, Int, LAM, LIT, Lam, RET, VAR,
}
import gleam/list
import gleam/set.{type Set}

pub fn lower(expr: Expr) -> List(Op) {
  case expr {
    Int(n) -> [LIT(n)]
    Ident(n) -> [VAR(n)]
    Lam(body) ->
      list.map(set.to_list(fvs(body, 1)), fn(n) { CAP(n - 1) })
      |> list.append([LAM(lower(body) |> list.append([RET]))])
    App(f, x) -> lower(f) |> list.append(lower(x)) |> list.append([APP])
  }
}

fn fvs(expr: Expr, depth: Int) -> Set(Int) {
  case expr {
    Int(_) -> set.new()
    Ident(n) if n >= depth -> set.from_list([n])
    Ident(_) -> set.new()
    Lam(body) -> fvs(body, depth + 1) |> set.map(fn(n) { n - 1 })
    App(f, x) -> fvs(f, depth) |> set.union(fvs(x, depth))
  }
}
