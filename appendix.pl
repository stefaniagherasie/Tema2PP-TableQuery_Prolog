:- module(appendix, [plus5/2, make_format_str/2, aux_format/2]).

plus5(X,Y):- Y is X + 5.
make_format_str(MaxRowLen,Str) :-
						maplist(plus5,MaxRowLen,Rp), aux_format(Rp,Str).
aux_format([H],R) :- 	string_concat("~t~w~t~",H,R1),
					 	string_concat(R1,"+~n",R),
					 	!.
aux_format([H|T],R) :- 	string_concat("~t~w~t~",H,R1),
						string_concat(R1,"+ ",R2),
						aux_format(T,Rp),
						string_concat(R2,Rp,R).