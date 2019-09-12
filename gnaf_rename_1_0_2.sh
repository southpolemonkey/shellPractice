#!/bin/bash

underscore="_"
backslash="/"
gzip_ext=".gz"
hash_ext=".hash"
dat_ext=".dat"
dat_gzip_ext=".dat.gz"

# setup variables
# source system code for G-NAF data
source_system="gnaf_ref"
source_extension="_psv.psv"
source_prefix=".*_"
authority_data_source_prefix="Authority_Code"

destination_prefix="$source_system$underscore"

# get the current datetime formatted
now="$(date +'%Y%m%d%H%M%S')"

# ==================================================
# array of files to be renamed
# ==================================================
# ordering is important as there is overlap in file names, specifically street_locality and locality. We process street locality first then locality after.
#
declare -a AddressDataArray=("ADDRESS_ALIAS_TYPE_AUT" "ADDRESS_CHANGE_TYPE_AUT" "ADDRESS_TYPE_AUT" "FLAT_TYPE_AUT" "GEOCODE_RELIABILITY_AUT" "GEOCODE_TYPE_AUT" "GEOCODED_LEVEL_TYPE_AUT" "LEVEL_TYPE_AUT" "STREET_LOCALITY_ALIAS_TYPE_AUT" "LOCALITY_ALIAS_TYPE_AUT" "LOCALITY_CLASS_AUT" "MB_MATCH_CODE_AUT" "PS_JOIN_TYPE_AUT" "STREET_CLASS_AUT" "STREET_SUFFIX_AUT" "STREET_TYPE_AUT" "ADDRESS_ALIAS" "ADDRESS_DEFAULT_GEOCODE" "ADDRESS_DETAIL" "ADDRESS_FEATURE" "ADDRESS_MESH_BLOCK_2011" "ADDRESS_MESH_BLOCK_2016" "ADDRESS_SITE_GEOCODE" "ADDRESS_SITE" "STREET_LOCALITY_ALIAS" "STREET_LOCALITY_POINT" "STREET_LOCALITY" "LOCALITY_ALIAS" "LOCALITY_NEIGHBOUR" "LOCALITY_POINT" "LOCALITY" "MB_2011" "MB_2016" "PRIMARY_SECONDARY" "STATE")

for val in ${AddressDataArray[@]}; do
	#set sequence to be 1
	seq=1

	# create the regex statement
	regex="$source_prefix$val$source_extension"

	# convert the tablename to lowercase
	tablename=$(echo "$val" | tr [:upper:] [:lower:])

	destinationfilename="$destination_prefix$tablename$underscore$now$underscore$seq"

	# list and loop through the filenames
	find . -type f -regex $regex | while read sourcefilename; do
		# create the destination filename
		dirname=`dirname "$sourcefilename"`
		basename=`basename "$sourcefilename"`

		echo "$basename"

		# rename the file
		if test $seq -eq 1;
		then
			head -n1 "$dirname$backslash$basename" >> "$destinationfilename$dat_ext"
		fi

		tail -n +2 "$dirname$backslash$basename" >> "$destinationfilename$dat_ext"

		rm "$sourcefilename"
		# increase the sequence
		let seq=$seq+1
	done

	# zip the file
	gzip "$destinationfilename$dat_ext"

	# create the hash filename
	newfilename="$destinationfilename$hash_ext"

	# create hashfile
	sha1sum "$destinationfilename$dat_gzip_ext" > "$newfilename"

done
