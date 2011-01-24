%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc TEMPLATE.

-module(bonds).
-author('author <author@example.com>').
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.

%% @spec start() -> ok
%% @doc Start the bonds server.
start() ->
    bonds_deps:ensure(),
    ensure_started(crypto),
    ensure_started(public_key),
    ensure_started(ssl),
    application:start(bonds).

%% @spec stop() -> ok
%% @doc Stop the bonds server.
stop() ->
    Res = application:stop(bonds),
    application:stop(crypto),
    Res.
