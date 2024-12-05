# FVM Prototype

(This is actually working right now! Modulo the small number of caveats I mention below.)

This is a rapid prototype of the Functional Virtual Machine (FVM). The final version would be written in C, Zig, or Rust. I used Gleam because it's the language I'm fastest and most comfortable with.

The FVM is an abstract machine that explores an interesting and under-researched design space. Namely, it handles immutability by cloning, opening the door to new optimizations and algorithmic considerations. If you consider it like using a Rust-style borrow checker that inserts clones until it's happy, then you can see that it doesn't need a garbage collector. If you've used Rust, you'll also know that that much cloning allows for quite a lot of safe in-place mutation. But more than that, FVM comes from the Gibbon compiler research tradition, which also commits to a more clone-heavy approach to vastly improve cache locality.

This codebase was just to make sure the abstract machine's transition rules actually run the lambda calculus correctly. Therefore there's no such low-level considerations like copying or garbage collection or whatever. That will come soon, in a different repo in a different codebase in a different programming language :)

Why an abstract machine? Notice how wildly easy it is to compile a functional language to FVM bytecode: there's no CPS conversion, no closure conversion, no SSA conversion, no hoisting, and no register allocation. The bytecode for `((λx.λy.x)(1))(2)` is just
```
LAM(CAP(0) LAM(VAR(1) RET) RET) LIT(1) APP LIT(2) APP
```
(In the low-level implementation, `LAM(List(Op))` will be `LAM(Int)` which is just the number of ops to skip over, which can be statically calculated by finding the corresponding `RET`, respecting nesting. So this representation is just a simplification for the purpose of the prototype, and it is much nicer for a functional language, which can't jump around a list very nicely.)

Notice how the bytecode maps so directly to the source code! This makes writing functional languages much much easier.

Someday I'd like to write an FVM AOT compiler to LLVM IR (or even just C), so I've also designed it to facilitate that, by using a call stack and returns instead of CPS. The language would benefit from looping instructions that I haven't thought too much about yet, but I'm unlikely to simply use tail calls.

I also need array instructions, which I haven't included here because this just needs to prove that lambda calculus runs correctly, and arrays are a little painful to represent in Gleam.

If you're interested in this project, the transition rules are in `src/runtime.gleam`. It's all wildly simple! I'm hoping that a real implementation, hopefully in Zig and without the parser I have here, will generally preserve the simplicity.