STACK_NAME=$1
COMPARTMENT=$2

export COMPARTMENT_OCID=$(oci iam compartment list --compartment-id-in-subtree true --all --output json | jq -r --arg name "$COMPARTMENT" '.data | map(select(.name == $name))[0]?.id')

export STACK_ID=$(oci resource-manager stack list --all --compartment-id $COMPARTMENT_OCID | jq ".data[] | select(.\"display-name\"==\"$STACK_NAME\").id" -r)

if [ -z "$STACK_ID" ]; then
    export STACK_ID=$(oci resource-manager stack create \
    --compartment-id $COMPARTMENT_OCID \
    --config-source stack.zip \
    --display-name "$STACK_NAME" \
    --wait-for-state ACTIVE | jq '.data.id' -r)
else
    oci resource-manager stack update \
    --stack-id $STACK_ID \
    --config-source stack.zip \
    --force
fi
# oci resource-manager job create-plan-job \
#     --stack-id $STACK_ID