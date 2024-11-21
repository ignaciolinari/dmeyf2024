# using Pkg
# Pkg.add("CSV")
# Pkg.add("DataFrames")

using CSV
using DataFrames

cd(raw"/home/clas_giulia_s/buckets/b1/datasets/")

periodo_anterior(x::Integer) =  x % 100 > 1  ?  x-1  : 12 + (div(x,100) -1) * 100

# Adjust input file name
df = CSV.read("competencia_02_crudo.csv.gz", DataFrame)
sort!(df, [:numero_de_cliente, :foto_mes])

global periodo_ultimo = maximum(df.foto_mes)
global periodo_anteultimo = periodo_anterior(periodo_ultimo)

# Assign most common class values
df.clase_ternaria = @. ifelse(df.foto_mes < periodo_anteultimo, "CONTINUA", missing)

# Precompute sequential time
periodo = @. div(df.foto_mes, 100) * 12 + df.foto_mes % 100

global last = nrow(df)

for i in 1:last
    if df.foto_mes[i] <= periodo_anteultimo && i < last &&
       (df.numero_de_cliente[i] != df.numero_de_cliente[i+1] || 
       df.numero_de_cliente[i] == df.numero_de_cliente[i+1] && periodo[i+1] > periodo[i] + 1)
        df.clase_ternaria[i] = "BAJA+1"
    end

    if df.foto_mes[i] < periodo_anteultimo && i+1 < last && 
       df.numero_de_cliente[i] == df.numero_de_cliente[i+1] && periodo[i+1] == periodo[i] + 1 &&
       (df.numero_de_cliente[i+1] != df.numero_de_cliente[i+2] || 
       df.numero_de_cliente[i+1] == df.numero_de_cliente[i+2] && periodo[i+2] > periodo[i+1] + 2)
        df.clase_ternaria[i] = "BAJA+2"
    end
end

# Adjust output file name
CSV.write("competencia_02.csv.gz", df)