import common.{
  type Expr, type Op, APP, App, CAP, Ident, Int, LAM, LIT, Lam, RET, VAR,
}
import gleam/list
import gleam/result.{unwrap}
import gleam/set.{type Set}

fn index(l: List(a), a: a) -> Result(Int, Nil) {
  case l {
    [] -> Error(Nil)
    [x, ..] if x == a -> Ok(0)
    [_, ..rest] -> result.map(index(rest, a), fn(n) { n + 1 })
  }
}

pub fn lower(expr: Expr, caps: List(Int)) -> List(Op) {
  case expr {
    Int(n) -> [LIT(n)]
    Ident(n) -> 
      case index(caps, n) {
        Error(Nil) -> [VAR(0)]
        Ok(idx) -> [VAR(idx + 1)]
      }
    Lam(body) -> {
      let body_caps = fvs(body, 1) |> set.to_list
      let body_caps_indices =
        list.map(body_caps, fn(n) { unwrap(index(caps, n - 1), -1) + 1 })
      list.append(list.map(list.reverse(body_caps_indices), CAP), [
        LAM(lower(body, body_caps) |> list.append([RET])),
      ])
    }
    App(f, x) -> lower(f, caps) |> list.append(lower(x, caps)) |> list.append([APP])
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
