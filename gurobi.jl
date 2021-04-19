using JuMP
using Gurobi
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



m = Model(Gurobi.Optimizer);
set_optimizer_attribute(m, "LogFile", "results.txt");


V=collect(1:num_of_vertex); 
E=collect(1:num_of_edges); 
C=collect(1:k); #COLORS



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

