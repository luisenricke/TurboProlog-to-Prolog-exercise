:-dynamic yes/1.
:-dynamic no/1.

start:-
  consult('DB.pl'),
  fail.
start:-
  assertz(yes(end)),
  assertz(no(end)),
  write("insert data(y/n): "),read(A),A=y,
  not(inserts),
  save_to_file('DB.pl'),!,
  ask([]),clean.
start:-
  ask([]),clean.
start:-
  clean.

inserts:-
  write("What's it? "),
  read(Obj),
  Obj\=="out",
  propertys(Obj,[]),
  write("more objects(y/n) "),!,
  read(Q),
  Q=y,
  inserts.


propertys(O,List):-
  write(O),write(" is/has/ makes: "),
  read(Attribute),
  Attribute\=='out',
  add(Attribute,List,List2),
  propertys(O,List2).
propertys(O,List):-
  assertz(info(O,List)),
  writeList(List,1),!,nl.

add(X,L,[X|L]).

ask(L):-
  info(O,A),
  not(element(O,L)),
  add(O,L,L2),
  beforeyes(A),
  beforeno(A),
  try(O,A),!,
  write(O),write(" Do you satisfy "),nl,
  write(" the current fields?"),nl,
  write("continue? (y/n)"),
  read(Q), Q=y,
  ask(L2).

beforeyes(A):-
  yes(T),!,
  xbeforeyes(T,A,[]),!.

xbeforeyes(end,_,_):-!.
xbeforeyes(T,A,L):-
  element(T,A),!,
  add(T,L,L2),
  yes(X),not(element(X,L2)),!,
  xbeforeyes(X,A,L2).

beforeno(A):-
  no(T),!,
  xbeforeno(T,A,[]),!.

xbeforeno(end,_,_):-!.
xbeforeno(T,A,L):-
  not(element(T,A)),!,
  add(T,L,L2),
  no(X),not(element(X,L2)),!,
  xbeforeno(X,A,L2).

try(_,[]).
try(O,[X|T]):-
  yes(X),!,
  try(O,T).
try(O,[X|T]):-
  write("is/has/ makes "),write(X),write(" "),
  read(Q),
  processing(O,X,Q),!,
  try(O,T).

processing(_,X,y):-
  asserta(yes(X)),!.
processing(_,X,n):-
  asserta(no(X)),!,fail.
processing(O,X,why):-
  write("I think it can be "),nl,
  write(O),write(" because it has: "),nl,
  yes(Z),xwrite(Z),nl,
  Z=end,!,
  write("is/has/ makes "),write(X),write("? "),
  read(Q),
  processing(O,X,Q),!.

xwrite(end).
xwrite(Z):-
  write(Z).

clean:-
  retract(yes(X)),
  X=end,fail.
clean:-
  retract(no(X)),
  X=end.

writeList([],_).
writeList([Head|Tail],3):-
  write(Head),nl,writeList(Tail,l).
writeList([Head|Tail],I):-
  N=I+1,
  write(Head),write(" "),writeList(Tail,N).


element(N,[N|_]).
element(N,[_|T]):- element(N,T).

save_to_file(File) :-
   open(File,write,Stream),
   with_output_to(Stream, listing),
   close(Stream).
