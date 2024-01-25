file_path=$1

for url in $(grep -Eo 'source\s+=\s+"([^"]+)"' "$file_path" | awk -F'"' '{print $2}'); do
  tag_number=$(echo "$url" | awk -F'=' '{print $2}')
  clean_url=$(echo "$url" | awk -F'::|?|//' '{print $2"//"$3}')
  echo "Cloning repository: $clean_url (Tag: $tag_number)"
  git clone --branch "$tag_number" --single-branch --depth 1 "$clean_url" > /dev/null 2> /dev/null &
done

echo "Updating sources..."
sed -i -E 's|source\s+=\s+"git::[^"]+/terraform-(.+)\?ref=.+"|source = "./terraform-\1"|; s|\.git//|/|; s|\.git|/|' "$file_path"

echo "Updating provider..."
cat <<EOL > provider.tf
provider "oci" {
  auth   = "InstancePrincipal"
  region = var.region
}
EOL

zip -r stack.zip . -x "*.terraform*" ".terraform/*" ".git/*" "backend.tf" "*.tfvars"