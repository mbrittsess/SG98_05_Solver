# SG98_05_Solver
Graphical &amp; genetic solvers for side profile of a Seitengewehr 98/05 bayonet

`manual_adjust.wlua52` is an interactive program, using IUPLua and CDLua, which allows one to adjust the variables that define the geometry of an SG98/05's blade's side profile. It can also evaluate all the constraints on the blade profile and show if they're being satisfied or violated (and by how much)

`de_run.lua` will run a (in retrospect, slightly flawed but still-functional) version of the *Self-Adaptive Differential Evolution* genetic algorithm to find a set of values for the defining variables which will satisfy all constraints on the blade profile.