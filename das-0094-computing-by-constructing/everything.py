#!/usr/bin/env python3

NULL = (
    lambda x: x
)

TRUE = (
    lambda t: lambda f: t(NULL)
)
FALSE = (
    lambda t: lambda f: f(NULL)
)
IF = (
    lambda cond: lambda t: lambda f: cond(t)(f)
)

ZERO = (
    lambda f: lambda x: x
)

ADD1 = (
    lambda n: lambda f: lambda x: f( n(f)(x) )
)
ADD = (
    lambda n: lambda m: n(ADD1)(m)
)

# Is this number equal to zero?
IS_ZERO = (
    lambda n: n(lambda x: FALSE)(TRUE)
)

# Subtract 1: opposite of S, so SUB1(ONE) == ZERO.
# Like Y, this is more complex and subtle than most
# of our functions have been. It's OK to skip over it
# during this introduction.
SUB1 = (
    (lambda n:
     lambda f:
     lambda x: n (lambda g: lambda h: h(g(f)))
                 (lambda u: x)
                 (lambda u: u))
)

# Multiplication: "add m to zero n times".
MULT = (
    lambda n: lambda m: n(lambda x:
                          ADD(x)(m))(ZERO)
)

ONE = (
    ADD1(ZERO)
)
SIX = (
    ADD1(ADD1(ADD1(ADD1(ADD1(ADD1(ZERO))))))
)
