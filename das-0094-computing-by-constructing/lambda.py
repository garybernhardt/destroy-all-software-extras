#!/usr/bin/env python3

ONE = 1
IS_ZERO = lambda x: x == 0
SUB1 = lambda x: x - 1
MULT = lambda x: lambda y: x * y
IF = lambda cond: lambda t_func: lambda f_func: t_func(None) if cond else f_func(None)

print(
    (
        lambda myself: (
            lambda n: (
                IF(
                    IS_ZERO(n)
                )(
                    lambda _: ONE
                )(
                    lambda _: MULT(n)( myself(myself)(SUB1(n)) )
                )
            )
        )
    )(
        lambda myself: (
            lambda n: (
                IF(
                    IS_ZERO(n)
                )(
                    lambda _: ONE
                )(
                    lambda _: MULT(n)( myself(myself)(SUB1(n)) )
                )
            )
        )
    )
    (6)
)
