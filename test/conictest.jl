#  Copyright 2016, Los Alamos National Laboratory, LANS LLC.
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.

function runconictests(algorithm, mip_solvers, conic_solvers)

facts("Default solvers test") do
    x = Convex.Variable(1,:Int)

    problem = Convex.maximize( 3x,
                        x <= 10,
                        x^2 <= 9)
    
    Convex.solve!(problem, PajaritoSolver())
    @fact problem.optval --> roughly(9.0, TOL)
end

facts("Default MIP solver test") do
    for conic_solver in conic_solvers
context("With $algorithm, $(typeof(conic_solver))") do
        x = Convex.Variable(1,:Int)

        problem = Convex.maximize( 3x,
                            x <= 10,
                            x^2 <= 9)
        
        Convex.solve!(problem, PajaritoSolver(cont_solver=conic_solver))
        @fact problem.optval --> roughly(9.0, TOL)
end
    end
end

facts("Default DCP solver test") do
    for mip_solver in mip_solvers
context("With $algorithm, $(typeof(mip_solver))") do
        x = Convex.Variable(1,:Int)

        problem = Convex.maximize( 3x,
                            x <= 10,
                            x^2 <= 9)
        
        Convex.solve!(problem, PajaritoSolver(mip_solver=mip_solver))
        @fact problem.optval --> roughly(9.0, TOL)
end
    end
end

facts("Infeasible Conic problem") do

    for mip_solver in mip_solvers
        for conic_solver in conic_solvers
context("With $algorithm, $(typeof(mip_solver)) and $(typeof(conic_solver))") do
            x = Convex.Variable(1,:Int)

            problem = Convex.maximize( 3x,
                                x >= 4,
                                x^2 <= 9)
            Convex.solve!(problem, PajaritoSolver(algorithm=algorithm,mip_solver=mip_solver,cont_solver=conic_solver))
            @fact problem.status --> :Infeasible
end
        end
    end

end

facts("Univariate maximization problem") do

    for mip_solver in mip_solvers
        for conic_solver in conic_solvers
context("With $algorithm, $(typeof(mip_solver)) and $(typeof(conic_solver))") do
            x = Convex.Variable(1,:Int)

            problem = Convex.maximize( 3x,
                                x <= 10,
                                x^2 <= 9)
            Convex.solve!(problem, PajaritoSolver(algorithm=algorithm,mip_solver=mip_solver,cont_solver=conic_solver))
            @fact problem.optval --> roughly(9.0, TOL)
end
        end
    end

end

facts("Continuous problem") do
    for mip_solver in mip_solvers
        for conic_solver in conic_solvers
context("With $algorithm, $(typeof(mip_solver)) and $(typeof(conic_solver))") do
            x = Convex.Variable(1)
            y = Convex.Variable(1, Convex.Positive())

            problem = Convex.maximize( 3x+y,
                                x >= 0,
                                3x + 2y <= 10,
                                exp(x) <= 10)

           Convex.solve!(problem, PajaritoSolver(algorithm=algorithm,mip_solver=mip_solver,cont_solver=conic_solver)) 
           @fact x.value --> roughly(log(10.0), TOL)
end
        end
    end

end

facts("Maximization problem") do
    for mip_solver in mip_solvers
        for conic_solver in conic_solvers
context("With $algorithm, $(typeof(mip_solver)) and $(typeof(conic_solver))") do
            x = Convex.Variable(1,:Int)
            y = Convex.Variable(1, Convex.Positive())

            problem = Convex.maximize( 3x+y,
                                x >= 0,
                                3x + 2y <= 10,
                                exp(x) <= 10)

           Convex.solve!(problem, PajaritoSolver(algorithm=algorithm,mip_solver=mip_solver,cont_solver=conic_solver)) 
           @fact problem.optval --> roughly(8.0, TOL)
end
        end
    end

end

facts("Solver test") do

    for mip_solver in mip_solvers
        for conic_solver in conic_solvers
context("With $algorithm, $(typeof(mip_solver)) and $(typeof(conic_solver))") do
            x = Convex.Variable(1,:Int)
            y = Convex.Variable(1)

            problem = Convex.minimize(-3x-y,
                               x >= 1,
                               y >= 0,
                               3x + 2y <= 10,
                               x^2 <= 5,
                               exp(y) + x <= 7)


            Convex.solve!(problem, PajaritoSolver(algorithm=algorithm,mip_solver=mip_solver,cont_solver=conic_solver)) 

            @fact problem.status --> :Optimal
            @fact Convex.evaluate(x) --> roughly(2.0, TOL)
end
        end
    end

end

facts("Turn on SOC disaggregator test") do

    for mip_solver in mip_solvers
        for conic_solver in conic_solvers
context("With $algorithm, $(typeof(mip_solver)) and $(typeof(conic_solver))") do
            x = Convex.Variable(1,:Int)
            y = Convex.Variable(1)

            problem = Convex.minimize(-3x-y,
                               x >= 1,
                               y >= 0,
                               3x + 2y <= 10,
                               x^2 + y^2 <= 5)


            Convex.solve!(problem, PajaritoSolver(disaggregate_soc=true,algorithm=algorithm,mip_solver=mip_solver,cont_solver=conic_solver)) 

            @fact problem.status --> :Optimal
            @fact Convex.evaluate(x) --> roughly(2.0, TOL)
            @fact Convex.evaluate(y) --> roughly(1.0, TOL)
end
        end
    end

end

facts("Turn off SOC disaggregator test") do

    for mip_solver in mip_solvers
        for conic_solver in conic_solvers
context("With $algorithm, $(typeof(mip_solver)) and $(typeof(conic_solver))") do
            x = Convex.Variable(1,:Int)
            y = Convex.Variable(1)

            problem = Convex.minimize(-3x-y,
                               x >= 1,
                               y >= 0,
                               3x + 2y <= 10,
                               x^2 <= 5,
                               exp(y) + x <= 7)


            Convex.solve!(problem, PajaritoSolver(algorithm=algorithm,disaggregate_soc=false,mip_solver=mip_solver,cont_solver=conic_solver)) 

            @fact problem.status --> :Optimal
            @fact Convex.evaluate(x) --> roughly(2.0, TOL)
end
        end
    end

end

facts("Solver test 2") do

    for mip_solver in mip_solvers
        for conic_solver in conic_solvers
context("With $algorithm, $(typeof(mip_solver)) and $(typeof(conic_solver))") do

            x = Convex.Variable(1,:Int)
            y = Convex.Variable(1, Convex.Positive())

            problem = Convex.minimize(-3x-y,
                               x >= 1,
                               3x + 2y <= 30,
                               exp(y^2) + x <= 7)

            Convex.solve!(problem, PajaritoSolver(algorithm=algorithm,mip_solver=mip_solver,cont_solver=conic_solver))

            @fact problem.status --> :Optimal
            @fact Convex.evaluate(x) --> roughly(6.0, TOL)
end
        end
    end

end


if algorithm == "OA"
facts("Print test") do

    for mip_solver in mip_solvers
        for conic_solver in conic_solvers
context("With $algorithm, $(typeof(mip_solver)) and $(typeof(conic_solver))") do
            x = Convex.Variable(1,:Int)
            y = Convex.Variable(1)

            problem = Convex.minimize(-3x-y,
                               x >= 1,
                               y >= 0,
                               3x + 2y <= 10,
                               x^2 <= 5,
                               exp(y) + x <= 7)

            Convex.solve!(problem, PajaritoSolver(verbose=1,profile=true,algorithm=algorithm,mip_solver=mip_solver,cont_solver=conic_solver))

            @fact problem.status --> :Optimal

end
        end
    end

end
end

end

function runSOCRotatedtests(algorithm, mip_solvers, conic_solver)

facts("Rotated second-order cone problem") do

    for mip_solver in mip_solvers
context("With $algorithm, $(typeof(mip_solver))") do
        problem = MathProgBase.ConicModel(PajaritoSolver(algorithm=algorithm,mip_solver=mip_solver,cont_solver=conic_solver))
        c = [-3.0; 0.0; 0.0;0.0]
        A = zeros(4,4)
        A[1,1] = 1.0
        A[2,2] = 1.0
        A[3,3] = 1.0
        A[4,1] = 1.0
        A[4,4] = -1.0
        b = [10.0; 3.0/2.0; 3.0; 0.0]
        constr_cones = Any[]
        push!(constr_cones, (:NonNeg, [1;2;3]))
        push!(constr_cones, (:Zero, [4]))
        var_cones = Any[]
        push!(var_cones, (:SOCRotated, [2;3;1]))
        push!(var_cones, (:Free, [4]))
        vartypes = [:Cont; :Cont; :Cont; :Int]
        MathProgBase.loadproblem!(problem, c, A, b, constr_cones, var_cones)
        MathProgBase.setvartype!(problem, vartypes) 

        MathProgBase.optimize!(problem)
        @fact MathProgBase.getobjval(problem) --> roughly(-9.0, TOL)
end
    end

end

end
