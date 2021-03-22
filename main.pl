:- use_module(tables).
:- use_module(check_predicates).
% Functiile din anexa se afla aici
:- use_module(appendix).


% TPRINT 

% calculeaza maxRowLen si obtine formatul lui Str, dupa care printeaza intrarile pe rand
print_table_op(Tbl) :- maxRowLen(Tbl, Max), make_format_str(Max, Str), print_entry(Tbl, Str).

% Obtine o lista cu lungimea elementelor de pe coloanele cu un indice dat Idx
%		- nth1 ia elementul de la pozitia Idx si il pune in Col
%		- string_length calculeaza lunginea lui Col in Len
%		- se adauga recursiv la rezultat lungimea fiecarui element de pe coloana Idx
columnLen([], _, []) :- !.
columnLen([Entry|T], Idx, [Len|R]) :- nth1(Idx, Entry, Col), string_length(Col, Len), 
									  columnLen(T, Idx, R).

% Calculeaza maximul dimensiunilor de pe coloana cu indicele Idx
maxColumnLen(Tbl, Idx, Max) :- columnLen(Tbl, Idx, R), max_list(R, Max).

% Obtine o lista cu dimensiunile maxime de pe fiecare coloana
maxLen(_, 0, []) :- !.
maxLen(Tbl, Len, [Max|R]) :- maxColumnLen(Tbl, Len, Max), NewLen is Len-1, 
							 maxLen(Tbl, NewLen, R).

% Calculeaza o lista in care se afla maximele de pe fiecare coloana
maxRowLen([Schema|T], R) :- length(Schema, Len), maxLen([Schema|T], Len, Rp), 
							reverse(Rp, R).

% Afiseaza pe rand fiecare intrare din tabel, respectand formatul dat
print_entry([], _) :- !.
print_entry([Entry|T], Str) :- format(Str, Entry), print_entry(T, Str).


% SELECT

% Calculeaza indicii coloanelor date pentru select si aplica selectarea pentru fiecare intrare
select_op(Cols, [Schema|T], [Cols|R]) :- getIndices(Schema, Cols, Idxs), 
										 applySelect(T, Idxs, R).

% Gaseste indicii coloanelor care trebuie selectate
getIndices(_, [], []) :- !.
getIndices(Schema, [Col|T], [Idx|R]) :- nth1(Idx, Schema, Col), getIndices(Schema, T, R).

% Selecteaza coloanele dintr-o linie care corespund indicilor
selectColumn(_, [], []) :- !.
selectColumn(Entry, [Idx|T], [Col|R]) :- nth1(Idx, Entry, Col), selectColumn(Entry, T, R).

% Aplica select pe fiecare intrare din tabel
applySelect([], _, []) :- !.
applySelect([Entry|T], Idx, [Rp|R]) :- selectColumn(Entry, Idx, Rp), applySelect(T, Idx, R).


% JOIN

% Aplica Op pe fiecare linie din cele 2 tabele si concateneaza NewCols ca header
join_op(Op, NewCols, [_|T1], [_|T2], [NewCols|R]) :- maplist(Op, T1, T2, R).


% FILTER

% Testeaza daca linia din tabel indeplineste conditiile impuse de Pred si 
% o concateneaza la rezultat in caz afirmativ
filter_op([], _, _, []).
filter_op([Entry|T], Vars, Pred, R) :- not((Vars = Entry, Pred)), filter_op(T, Vars, Pred, R), !.
filter_op([Entry|T], Vars, Pred, [Entry|R]) :- filter_op(T, Vars, Pred, R).


% COMPLEX_QUERY1

% Evalueaza o tabela de tip studenti si o filtreaza dupa regulile impuse in cerinta
complex_query1_op(Tbl, R) :- eval(tfilter([_, LastN, AA, PP, PC, PA, POO], 
										  ((AA + PP)/2 > 6, (AA+PP+PC+PA+POO)/5 > 5, 
										  sub_string(LastN,_,_,_,"escu")), Tbl), R).


% COMPLEX_QUERY2

% Filtreaza filmele care au un gen dat si au rating-ul aflat intr-un interval dat
%		- se filtreaza filmele care au genul respectiv
%		- se selecteaza coloana "movie_id" din tabela obtinuta
%		- se obtin coloanele "movie_id" si "rating" din tabela cu rating-uri
%		- se sorteaza aceasta dupa rating
%		- ii se adauga headerul care a trebuit ignorat anterior pentru a putea face sortarea
%		- se extrag din aceasta doar intrarile care au movie_id identificat la pasul 2
%		- se selecteaza doar coloana de rating care se concateneaza la tabelul de la pasul 1 
%		- se iau doar intrarile care au rating-ul in intervalul dat
complex_query2_op(Genre, MinR, MaxR, R) :- 	
		eval(tfilter([_,_, GN], sub_string(GN,_,_,_, Genre), table(movies)), R1),
		eval(select(["movie_id"], entries(R1)), [_|R2]),
		eval(select(["movie_id", "rating"], table(ratings)), [_|R3]),
		sort(0, @=<, R3, R4), append([["movie_id","rating"]], R4, R5),
		eval(tfilter([MI, _], member([MI], R2), entries(R5)), R6),
		eval(select(["rating"], entries(R6)), R7),
		eval(join(append, ["movie_id","title","genres","rating"], entries(R1), entries(R7)), R8),
		eval(tfilter([_,_,_,RT], (RT >= MinR, MaxR >= RT), entries(R8)), R).


% EVAL

% Evalueaza Query-uri
eval(entries(Tbl), Tbl).
eval(table(Name), R) :- table_name(Name, R). 
eval(tprint(Tbl), R) :- eval(Tbl, R), print_table_op(R).
eval(select(Cols, Query), R) :- eval(Query, T), call(select_op, Cols, T, R).
eval(join(Op, NewCols, Query1, Query2), R) :- eval(Query1, T1), eval(Query2, T2), 
											  call(join_op, Op, NewCols, T1, T2, R).
eval(tfilter(Vars, Pred, Query), [H|R]) :- eval(Query, [H|T]), call(filter_op, T, Vars, Pred, R).
eval(complex_query1(Tbl), R) :- call(complex_query1_op, Tbl, R).
eval(complex_query2(Genre, MinR, MaxR), R) :- call(complex_query2_op, Genre, MinR, MaxR, R).