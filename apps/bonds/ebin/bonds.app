{application, bonds,
 [{description, "bonds"},
  {vsn, "0.1"},
  {modules, [
    bonds,
    bonds_app,
    bonds_sup,
    bonds_web,
    bonds_deps,
    n_bonds
  ]},
  {registered, []},
  {mod, { bonds_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.
