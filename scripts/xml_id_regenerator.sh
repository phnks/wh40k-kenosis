xml_directory=".."

declare -A id_map
weird_uuid_pattern='[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}'
pub_uuid_pattern='[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-zA-Z]{9}'
uuid_pattern='[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

#for file in "$xml_directory"/Warhammer\ 40\,000.gst; do
#for file in "$xml_directory"/Imperium\ -\ Adeptus\ Mechanicus.cat; do
for file in "$xml_directory"/*.{gst,cat}; do
	echo $file
	if [ -f "$file" ]; then
		ids=($(grep -oiE "id=\"[^\"]*\"|Id=\"[^\"]*\"|field=\"[^\"]*\"|scope=\"[^\"]*\"|value=\"[^\"]*\"" "$file"))
		for id in "${ids[@]}"; do
		     if [[ $id =~ $uuid_pattern ]] || [[ $id =~ $weird_uuid_pattern ]] || [[ $id =~ $pub_uuid_pattern ]]; then
			    echo "OLD: "$id
			    id_lower=$(echo "$id" | tr '[:upper:]' '[:lower:]' | sed 's/field/id/g; s/scope/id/g; s/value/id/g')
			    if [[ -z "${id_map[$id_lower]}" ]]; then
				new_uuid=$(uuidgen)
				id_map["$id_lower"]=$new_uuid
			    else
				new_uuid="${id_map[$id_lower]}"
			    fi

			    echo "NEW: "$new_uuid

			    if [[ $id == "id=\""* ]]; then
				sed -i "s/$id/id=\"$new_uuid\"/g" "$file"
			    elif [[ $id == "field=\""* ]]; then
				sed -i "s/$id/field=\"$new_uuid\"/g" "$file"
			    elif [[ $id == "scope=\""* ]]; then
				sed -i "s/$id/scope=\"$new_uuid\"/g" "$file"
			    elif [[ $id == "value=\""* ]]; then
				sed -i "s/$id/value=\"$new_uuid\"/g" "$file"
			    else
				sed -i "s/$id/Id=\"$new_uuid\"/g" "$file"
			    fi		
		    fi
	    done
	fi
done

echo "All ID tags replaced with new UUIDs in XML files."
