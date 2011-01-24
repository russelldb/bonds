%% @author author <russell@ossme.net>
%% @copyright 2011 Russell Brown.

%% @doc Web server for bonds.

-module(bonds_web).
-author('author <russell@ossme.net>').

-export([start/0, stop/0, loop/2]).

%% External API

start() ->
    %% Read config...
    {ok, BindAddress} = application:get_env(bonds, bind_address),
    {ok, Port} = application:get_env(bonds, port),
    {ok, ServerName} = application:get_env(bonds, server_name),
    {ok, DocRoot} = application:get_env(bonds, document_root),

    Loop = fun (Req) ->
		   ?MODULE:loop(Req, DocRoot)
	   end,

    Options = [
        {name, ServerName},
        {ip, BindAddress}, 
        {port, Port},
        {loop, Loop}
    ],

    error_logger:info_msg("Starting mochiweb with options: ~p~n", [Options]),

    mochiweb_http:start(Options).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req, DocRoot) ->
       "/" ++ Path = Req:get(path),
    error_logger:info_msg("Got request like ~p~n", [Path]),
    try
        case Req:get(method) of
            Method when Method =:= 'GET'; Method =:= 'HEAD' ->
                case Path of
		    [] ->
			Req:serve_file("bonds.swf8.swf", DocRoot);
		    P ->
			N = list_to_integer(P),
			Bonds = n_bonds:bonds_square_for_xml(N),
			Export=xmerl:export_simple([Bonds],xmerl_xml),
			Req:respond({200, [{"Content-Type", "application/xml"}],
				     lists:flatten(Export)})
                   
                end;
            'POST' ->
                case Path of
                    _ ->
                        Req:not_found()
                end;
            _ ->
                Req:respond({501, [], []})
        end
    catch
        Type:What ->
            Report = ["web request failed",
                      {path, Path},
                      {type, Type}, {what, What},
                      {trace, erlang:get_stacktrace()}],
            error_logger:error_report(Report),
            %% NOTE: mustache templates need \ because they are not awesome.
            Req:respond({500, [{"Content-Type", "text/plain"}],
                         "request failed, sorry\n"})
    end.



%% Internal API
%% Figure out the view name
get_view("") ->
	"bonds.swf8.swf";
get_view(Path) ->
	filename:rootname(filename:basename(Path)).
