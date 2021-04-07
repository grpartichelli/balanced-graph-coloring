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
  
edges = []
#REST OF THE INFO
for line in readlines(f)
	if(line != "")
		l = split(line, " ");
		edge = [parse(Int64, x) for x in l];
	    push!(edges,(edge[1]+1,edge[2]+1));  
	end   
end
close(f)
#########################################################################

V=collect(1:num_of_vertex); 
E=collect(1:num_of_edges); 
C=collect(1:k); #COLORS

m = Model();

set_optimizer(m, GLPK.Optimizer);


@variable(m,maxWeight >= 0);		            #(bigger then the points of the color with max points (will be minimized, forcing it equal to max))
@variable(m, 1 >= x[i in V, j in C] >= 0,Int);  #(true if vertice i has color j)
@variable(m, y[j in C] >= 0); 		            #(total weight of a color)

@objective(m, Min, maxWeight);



#All adjacent nodes must have different colors
for j in C
	for uv in edges
		u = uv[1];
		v = uv[2];
		@constraint(m, (x[u,j] + x[v,j]) <= 1);
	end
end

#Weight of color j
for j in C
	@constraint(m, y[j] == sum( (x[i,j]*weights[i]) for i in V) );
end

#Points of the color with max points (will be minimized so it ends up equal to the max))
for  j in C
	@constraint(m,maxWeight >= y[j]);
end


#All nodes have a single color
for i in V
	@constraint(m, sum(x[i,j] for j in C) == 1);
end
###


optimize!(m);



printfmt("O melhor resultado é {:.2f}\n",objective_value(m));

#=

for j in C
	for i in V
		printfmt("{:.2f} - {:.2f}.\n",j,value(x[i,j]) );
	end
end

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