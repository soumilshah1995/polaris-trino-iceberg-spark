#!/bin/bash

# Environment variables
export AWS_ACCOUNT_ID="XXXX"
export POLICY_NAME="snowflake_access"
export POLICY_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:policy/$POLICY_NAME"
export ROLE_NAME="snowflakes_role"

# Step 1: Check and detach the policy from any roles
roles=$(aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query 'PolicyRoles[].RoleName' --output text)
if [ -n "$roles" ]; then
    for role in $roles; do
        echo "Detaching policy from role $role..."
        aws iam detach-role-policy --role-name "$role" --policy-arn "$POLICY_ARN"
    done
else
    echo "No roles found attached to the policy."
fi

# Step 2: Check and detach the policy from any users
users=$(aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query 'PolicyUsers[].UserName' --output text)
if [ -n "$users" ]; then
    for user in $users; do
        echo "Detaching policy from user $user..."
        aws iam detach-user-policy --user-name "$user" --policy-arn "$POLICY_ARN"
    done
else
    echo "No users found attached to the policy."
fi

# Step 3: Check and detach the policy from any groups
groups=$(aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query 'PolicyGroups[].GroupName' --output text)
if [ -n "$groups" ]; then
    for group in $groups; do
        echo "Detaching policy from group $group..."
        aws iam detach-group-policy --group-name "$group" --policy-arn "$POLICY_ARN"
    done
else
    echo "No groups found attached to the policy."
fi

# Step 4: Delete all non-default policy versions
versions=$(aws iam list-policy-versions --policy-arn "$POLICY_ARN" --query 'Versions[?IsDefaultVersion==`false`].VersionId' --output text)
for version in $versions; do
  echo "Deleting policy version $version..."
  aws iam delete-policy-version --policy-arn "$POLICY_ARN" --version-id "$version"
done

# Step 5: Delete the IAM policy
aws iam delete-policy --policy-arn "$POLICY_ARN"

echo "Policy detached from all entities and deleted successfully!"
