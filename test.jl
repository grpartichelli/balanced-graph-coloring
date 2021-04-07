using JuMP
using GLPK
using Formatting
########################################################################
filename = "cmb/cmb01";
f = open(filename, "r");

# FIRST LINE INFO
first_line = split(readline(f), " ");

num_of_vertex = parse(Int64,first_line[1]);
num_of_edges = parse(Int64,first_line[2]);
k = parse(Int64,first_line[3]);

# SECOND LINE INFO
second_line =  split(readline(f), " ");
weights =  [parse(Float64, x) for x in second_line];
  
vertices = []
#REST OF THE INFO
for line in readlines(f)
	if(line != "")
		l = split(line, " ");
		vertice = [parse(Int64, x) for x in l];
	    push!(vertices,(vertice[1],vertice[2]));  
	end   
end
close(f)
#########################################################################


println(vertices);



#=
I=collect(1:3); V=collect(1:3);

m = Model()
set_optimizer(m, GLPK.Optimizer);
@variable(m, x[i in I, v in V] >= 0);

pv=[68, 57, 45];

ci=[70, 50, 40];

@variable(m, y[v in V]) ## total vendas
@variable(m, z[i in I]) ## total importação
@objective(m, Max, sum(pv[v]*y[v] for v in V)-sum(ci[i]*z[i] for i in I))

@constraint(m, [v in V], y[v]==sum(x[i,v] for i in I))
@constraint(m, [i in I], z[i]==sum(x[i,v] for v in V));

li=[2000,2500,1200];

@constraint(m, [i in I], z[i] <= li[i]);

@constraint(m,x[1,1] >= 0.6 *y[1]) ## no mínimo 60% Johnny Ballantine em A
@constraint(m, x[3,1] <= 0.2 *y[1]) ## no máximo 20% Misty Deluxe em A

@constraint(m, x[1,2] >= 0.15*y[2]) ## no mínimo 15% Johnny Ballantine em B
@constraint(m, x[3,2] <= 0.6 *y[2]) ## no máximo 60% Misty Deluxe em B

@constraint(m, x[3,3] <= 0.6 *y[3]); ## no máximo 50% Misty Deluxe em C

println(m)
optimize!(m)

printfmt("O lucor máximo é {:.2f}.\n",objective_value(m))
printfmt("Importar {:.2f} garrafas de Johnny Ballantine, {:.2f} garrafas de Old Gargantua, e {:.2f} garrafas de Misty Deluxe.",value(z[1]),value(z[2]),value(z[3]) )
for v in V
    printfmt("Mistura {}: {:.2f} garrafas.\n","ABC"[v],value(y[v]))
    if value(y[v])>0
      printfmt("  {:.2f}% JB, {:.2f}% OG, {:.2f}% MD.\n","ABC"[v],value(x[1,v])/value(y[v]),value(x[2,v])/value(y[v]),value(x[3,v])/value(y[v]))
    end
end
=#