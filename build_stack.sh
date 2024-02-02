file_path=$1

for url in $(grep -Eo 'source\s+=\s+"([^"]+)"' "$file_path" | awk -F'"' '{print $2}'); do
  tag_number=$(echo "$url" | awk -F'=' '{print $2}')
  clean_url=$(echo "$url" | awk -F'::|?|//' '{print $2"//"$3}')
  echo "Cloning repository: $clean_url (Tag: $tag_number)"
  echo "Cloning repository: $clean_url (Tag: $tag_number)"  >>  versions
  git clone --branch "$tag_number" --single-branch --depth 1 "$clean_url"
done

echo "Updating sources..."
sed -i -E 's|source\s+=\s+"git::[^"]+/terraform-(.+)\?ref=.+"|source = "./terraform-\1"|; s|\.git//|/|; s|\.git|/|' "$file_path"

echo "Updating provider..."
cat <<EOL > provider.tf
provider "oci" {
  auth   = "InstancePrincipal"
  region = var.region
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
}
EOL

zip -r stack.zip . -x "*.terraform*" ".terraform/*" ".git/*" "backend.tf" "*.tfvars"