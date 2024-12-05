import common.{type Expr, App, Ident, Int, Lam}
import gleam/int
import party

pub fn int() -> party.Parser(Expr, Nil) {
  party.digits()
  |> party.map(fn(digits) {
    let assert Ok(n) = int.parse(digits)
    Int(n)
  })
}

fn index(scope: List(String), name: String) -> Int {
  case scope {
    [] -> panic as { "unknown identifier " <> name }
    [x, ..] if x == name -> 0
    [_, ..rest] -> 1 + index(rest, name)
  }
}

pub fn ident_string() -> party.Parser(String, Nil) {
  use first <- party.do(party.lowercase_letter())
  use rest <- party.do(
    party.many_concat(party.either(party.alphanum(), party.char("_"))),
  )
  party.return(first <> rest)
}

pub fn ident(scope: List(String)) -> party.Parser(Expr, Nil) {
  ident_string()
  |> party.map(fn(name) { Ident(index(scope, name)) })
}

pub fn lambda(scope: List(String)) -> party.Parser(Expr, Nil) {
  use _ <- party.do(party.char("\\"))
  use _ <- party.do(party.whitespace())
  use name <- party.do(ident_string())
  use _ <- party.do(party.whitespace())
  use _ <- party.do(party.char("."))
  use body <- party.do(expr([name, ..scope]))
  party.return(Lam(body))
}

fn parens(scope: List(String)) -> party.Parser(Expr, Nil) {
  use _ <- party.do(party.char("("))
  use e <- party.do(expr(scope))
  use _ <- party.do(party.char(")"))
  party.return(e)
}

pub fn expr(scope: List(String)) -> party.Parser(Expr, Nil) {
  use _ <- party.do(party.whitespace())
  use e1 <- party.do(
    party.choice([parens(scope), int(), ident(scope), lambda(scope)]),
  )
  use _ <- party.do(party.whitespace())
  use res <- party.do(party.perhaps(parens(scope)))
  use _ <- party.do(party.whitespace())
  case res {
    Ok(e2) -> party.return(App(e1, e2))
    Error(_) -> party.return(e1)
  }
}

pub fn parse(code: String) -> Expr {
  let assert Ok(out) = party.go(expr([]), code)
  out
}
