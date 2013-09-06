-module(kterl_app).
-behaviour(application).
-behaviour(supervisor).

-export([start/0, stop/0]).
-export([start/2, stop/1]).
-export([init/1]).

start() ->
    application:start(?MODULE).

stop() ->
    application:stop(?MODULE).

start(_Type, _Args) ->
    supervisor:start_link({local, kterl}, ?MODULE, []).

stop(_State) ->
    ok.

init([]) ->
    {ok, Pools} = application:get_env(kterl, pools),
    PoolSpecs = lists:foldl(fun({Name,[{host,_}=Host, {port,_}=Port, {reconnect_sleep,_} = Timeout]},Acc)->
				    [{kterl,{kterl, start_link, [[{name,Name},Host,Port,Timeout]]}, temporary, 2000, worker, dynamic}|Acc];
			       (_E,Acc) ->
				    io:format("~n dont know how to read kterl opts ~p",[_E]),
				    Acc	
			    end, [], Pools),
    io:format("~n starting kterl with ~p",[PoolSpecs]),
    {ok, {{one_for_one, 10, 10}, PoolSpecs}}.

