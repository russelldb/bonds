-module (n_bonds).
-compile(export_all).


%gets the number bonds of N
bonds(N) -> 
	X = [{A,N-A} || A <- lists:seq(0, N div 2)],
	lists:umerge(X, lists:map(fun(T) -> 
					reverse_tuple(T)
					end, lists:reverse(X) ) ).
						

%get bonds that may look right to a 5 year old (but are wrong) for N (basically bonds of N+1 and N-1 with any bonds that are > N removed)			
bad_bonds(N) ->
	%is this a hack? it is only very small numbers (1 and 3 as far as I know) where this is a problem
	case N < 4 of
		true -> [ A || A <- lists:append(bonds(N+1),bonds(N-1)), both_less_than_or_equal(N, A)];
		false ->
	[ A || A <- lists:append(bonds(N+1),bonds(N-1)),
			both_less_than(N, A)
			]
		end.
		

reverse_tuple(T) ->
	list_to_tuple(lists:reverse(tuple_to_list(T))).

			
%returns true of both A and B are less than N
both_less_than(N, {A, B}) ->
	A < N andalso B < N.
	
%returns true of both A and B are less than or equal N
both_less_than_or_equal(N, {A, B}) ->
	A =< N andalso B =< N.

	
%returns true if N is square number			
is_square(N) -> 
	X = math:sqrt(N),
	round(X) == X.

%All the square numbers up to N
all_squares_to(N) ->
	[A || A <- lists:seq(0, N),
				is_square(A)
				].

%The first square number after N (even if N is a square)
next_square(N) ->
	first_greater_than(N, all_squares_to(N*3)).

%the first number in list that is greater than N
first_greater_than(N, [H|T]) ->
	case H > N of
		true -> H;
		false -> first_greater_than(N, T)
	end;
%there is no number greater (oh dear, but there will be, see from whence it is called above (next_square/1))
first_greater_than(_N, []) ->
	[].
	
%pads list L with items at random from R until L has N elements
pad_list_at_random(L, R, N) ->
	if 
		length(L) + length(R) < N ->
			throw("length of l and r is less than N");
		true ->
			void
	end,
	case length(L) == N of
		true -> L;
		false -> X = pick_at_random(R),  pad_list_at_random([X|L], lists:delete(X,R), N)
	end.


%picks a member of L at random and returns it
pick_at_random(L) ->
	{A, B, C} = now(),
	random:seed(A, B, C),
	lists:nth(random:uniform(length(L)), L).
	

%get a list of bonds for N padded out with incorrect bonds
bonds_square(N) ->
	Bonds = bonds(N),
	BadBonds = bad_bonds(N),
	To = next_square(length(Bonds)),
	L = pad_list_at_random(Bonds, BadBonds, To),
	my_randomize(L).
	
	
bonds_square_for_xml(N) ->
	L = bonds_square(N),
	BL = [{bond, [{b1,A},{b2,B}],[string:concat(string:concat(integer_to_list(A), "+"), integer_to_list(B))]} || {A,B} <- L],
	{bonds,[{for,integer_to_list(N)},{total, integer_to_list(length(BL))}], BL}.
	
export_as_xml(N) ->
	Bonds = bonds_square_for_xml(N),
	File = string:concat(string:concat("/Users/russell/development/openlazslo/bonds-", integer_to_list(N)), ".xml"),
	{ok,IOF}=file:open(File,[write]),
	Export=xmerl:export_simple([Bonds],xmerl_xml),
	io:format(IOF,"~s~n",[lists:flatten(Export)]).
	

	
t(L) ->
	{_, T} = statistics(runtime),
	io:format("~p : ~p~n", [L,T]).
	
shuffle(List) ->
%% Determine the log n portion then randomize the list.
   randomize(round(math:log(length(List)) + 0.5), List).

randomize(1, List) ->
   randomize(List);
randomize(T, List) ->
   lists:foldl(fun(_E, Acc) ->
                  randomize(Acc)
               end, randomize(List), lists:seq(1, (T - 1))).

randomize(List) ->
   {Z, X, Y} = now(),
   random:seed(Z, X, Y),
   D = lists:map(fun(A) ->
                    {random:uniform(), A}
             end, List),
   {_, D1} = lists:unzip(lists:keysort(1, D)), 
   D1.


my_randomize(L) ->
	randomize_accumulator(L, []).

randomize_accumulator(L, Randomized) ->
	case length(L) == 0 of
		true -> Randomized;
		false ->
			X = pick_at_random(L),
			randomize_accumulator(lists:delete(X, L), [X|Randomized])
	end.