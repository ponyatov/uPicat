
import os,sys

MODULE = sys.argv[0].split('/')[-1]
INI    = sys.argv[0][-3:]+'.ini'

## homoiconic frame system

class Frame:

    def __init__(self,V):
        self.type = self.__class__.__name__.lower()
        self.val  = V
        self.slot = {}
        self.nest = []

    ## dump

    def __repr__(self): return self.dump()
    def dump(self,depth=0,prefix=''):
        tree = self._pad(depth) + self.head(prefix)
        return tree
    def head(self,prefix=''):
        return '%s<%s:%s> @%x' % (prefix,self.type,self._val(),id(self))
    def _pad(self,depth):
        return '\n' + ' '*4 * depth
    def _val(self):
        return str(self.val)

    ## operators

    def __getitem__(self,key):
        return self.slot[key]
    def __setitem__(self,key,that):
        if callable(that): self[key] = Cmd(that) ; return self
        if not isinstance(that,Frame): raise TypeError(that)
        self.slot[key] = that ; return self
    def __floordiv__(self,that):
        if not isinstance(that,Frame): raise TypeError(that)
        self.nest.append(that) ; return self

    ## stack ops

    def pop(self): return self.nest.pop(-1)
    def top(self): return self.nest[-1]

class Primitive(Frame): pass

class Symbol(Primitive): pass
class String(Primitive): pass

class Active(Frame): pass

class VM(Active): pass

class Cmd(Active):
    def __init__(self,F):
        Active.__init__(self,F.__name__)
        self.fn = F
    def eval(self,ctx):
        self.fn(ctx)

## global virtual machine

vm = VM(MODULE)

## manipulations

def EQ(ctx): addr = ctx.pop().val ; ctx[addr] = ctx.pop()
vm['='] = EQ

## no-syntax parser

import ply.lex as lex

tokens = ['symbol']

t_ignore         = ' \t\r\n'
t_ignore_comment = r'[\#\\].*'

def t_symbol(t):
    r'[`]|[^ \t\r\n\#\\]+'
    return Symbol(t.value)

def t_ANY_error(t): raise SyntaxError(t)

## interpreter

def WORD(ctx):
    token = ctx.lexer.token()
    if token: ctx // token
    return token
vm['`'] = WORD

def FIND(ctx):
    token = ctx.pop()
    try:             ctx // ctx[token.val] ; return True
    except KeyError: ctx // token          ; return False

def EVAL(ctx): ctx.pop().eval(ctx)

def INTERP(ctx):
    ctx.lexer = lex.lex() ; ctx.lexer.input(ctx.pop().val)
    while True:
        if not WORD(ctx): break
        if isinstance(ctx.top(),Symbol):
            if not FIND(ctx): raise SyntaxError(ctx.top())
        EVAL(ctx)

## system .ini

if __name__ == '__main__':
    for i in sys.argv[1:]:
        with open(i) as src:
            vm // String(src.read()) ; INTERP(vm)

## Web/Flask

import flask

web = flask.Flask(__name__)
web.run(host=vm['HOST'].val,port=vm['PORT'].val,debug=True,extra_files=[INI])
