
:-dynamic si/1.
:-dynamic no/1.

start:-
  consult('db.pl'),
  fail.
start:-
  assertz(si(end)),
  assertz(no(end)),
  write("Introducir informacion (s/n): "),read(A),A=s,
  not(introducir),
  save_to_file('db.pl'),!,
  preguntar([]),purgar.
start:-
  preguntar([]),purgar.
start:-
  purgar.

/*Pide el nombre del objeto para introducirlo
a la base del conocimiento*/
introducir:-
  write("Que es: "),
  read(Obj),
  Obj\=="salir",
  atributos(Obj,[]),
  write("mas (s/n) "),!,
  read(Q),
  Q=s,
  introducir.

/*Pide los atributos del objeto para introducirlo
a la base del conocimiento*/
atributos(O,List):-
  write(O),write(" es/tiene/hace: "),
  read(Attribute),
  Attribute\=='salir',
  agregar(Attribute,List,List2),
  atributos(O,List2).
atributos(O,List):-
  assertz(info(O,List)),
  escribirLista(List,1),!,nl.

agregar(X,L,[X|L]).

preguntar(L):-
  info(O,A),
  not(miembro(O,L)),
  agregar(O,L,L2),
  anterioressi(A),
  anterioresno(A),
  intentar(O,A),!,
  write(O),write(" satisface los"),nl,
  write("atributos actuales"),nl,
  write("continuar (s/n)"),
  read(Q), Q=s,
  preguntar(L2).

anterioressi(A):-
  si(T),!,
  xanterioressi(T,A,[]),!.

xanterioressi(end,_,_):-!.
xanterioressi(T,A,L):-
  miembro(T,A),!,
  agregar(T,L,L2),
  si(X),not(miembro(X,L2)),!,
  xanterioressi(X,A,L2).

anterioresno(A):-
  no(T),!,
  xanterioresno(T,A,[]),!.

xanterioresno(end,_,_):-!.
xanterioresno(T,A,L):-
  not(miembro(T,A)),!,
  agregar(T,L,L2),
  no(X),not(miembro(X,L2)),!,
  xanterioresno(X,A,L2).

intentar(_,[]).
intentar(O,[X|T]):-
  si(X),!,
  intentar(O,T).
intentar(O,[X|T]):-
  write("es/tiene/hace "),write(X),write(" "),
  read(Q),
  procesar(O,X,Q),!,
  intentar(O,T).

procesar(_,X,s):-
  asserta(si(X)),!.
procesar(_,X,n):-
  asserta(no(X)),!,fail.
procesar(O,X,why):-
  write("Creo que puede ser"),nl,
  write(O),write(" por que tiene: "),nl,
  si(Z),xwrite(Z),nl,
  Z=end,!,
  write("es/tiene/hace "),write(X),write("? "),
  read(Q),
  procesar(O,X,Q),!.

xwrite(end).
xwrite(Z):-
  write(Z).

purgar:-
  retract(si(X)),
  X=end,fail.
purgar:-
  retract(no(X)),
  X=end.

escribirLista([],_).
escribirLista([Head|Tail],3):-
  write(Head),nl,escribirLista(Tail,l).
escribirLista([Head|Tail],I):-
  N=I+1,
  write(Head),write(" "),escribirLista(Tail,N).


miembro(N,[N|_]).
miembro(N,[_|T]):- miembro(N,T).

save_to_file(File) :-
   open(File,write,Stream),
   with_output_to(Stream, listing),
   close(Stream).
