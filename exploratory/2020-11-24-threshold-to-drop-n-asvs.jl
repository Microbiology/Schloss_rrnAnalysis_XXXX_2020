#!/usr/bin/env julia
# Geof Hannigan

#################
# Load Packages #
#################

# Start by setting up the required packages
using Pkg
Pkg.add("DataFrames")
Pkg.add("Queryverse")
Pkg.add("Gadfly")
using DataFrames
using Queryverse
using Statistics
using Gadfly

#####################
# Load In The Files #
#####################

# First set the file names
metafile = "data/references/genome_id_taxonomy.tsv"
easv_file = "data/processed/rrnDB.easv.count_tibble.tsv"

# Then bring those files in
metadata = DataFrame(load(metafile))
easv = DataFrame(load(easv_file))

# Take a look at the data dataframes (top 10 lines)
first(metadata, 10)
first(easv, 10)

# Merge together
metadata_easv = innerjoin(metadata, easv, on = [:genome_id => :genome])
first(metadata_easv, 10)

outdf = groupby(metadata_easv, [:region, :threshold, :genome_id])

summarydf = combine(outdf, :count => sum, nrow)

# Determine 95%-tile
tileoutdf = groupby(summarydf, [:region, :threshold, :count_sum])
combotile = combine(tileoutdf, :nrow => t -> quantile(t, .95))

# Plot the 95th percentile as a function of region,  threshold, #rrns
plot(combotile, ygroup=:region, x=:count_sum, y=:nrow_function, color=:threshold, Geom.subplot_grid(Geom.line))



