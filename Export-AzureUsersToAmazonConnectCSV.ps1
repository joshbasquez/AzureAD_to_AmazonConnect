# script to generate list of azuread users 
# for import into Amazon Connect
# 
# Prerequisites:
# - Azure Powershell module: Install-Module -Name Az -Repository PSGallery -Force
# - Connection to Azure Account: Connect-AzAccount
# - Single-Sign On for Azure Accounts into Amazon Connect. 
# - This script assumes the full upn is passed in the Azure App Claims
#   where Claim Name https://aws.amazon.com/SAML/Attributes/RoleSessionName = user.userprincipalname
#   if another claims value is being passed, edit line: $r."user login" = $m.<desiredValue>

# Description: 
# script prompts for an AzureAD Group displayname
# the members of this group are collected and exported to a csv
# the csv can be imported into Amazon Connect by a Connect Administrator
# Connect -> User Management -> Add new users -> Import Users using a .csv template
# Upload the csv file generated by this script


# define export file
$exportFile = "connectusers.csv"


# Script Begin:

# define results array
$results = @()

# prompt for azureAD group displayname
$groupName = read-host "enter group displayname"


$groupMembers = Get-AzADGroupMember -GroupDisplayName $groupName
if($groupMembers){
"$($groupMembers.count) group members found. collecting attributes..."
foreach($m in $groupMembers){

# define attributes
$r = "" | select "first name","last name","secondary email","mobile","user login","routing profile name","security_profile_name_1|security_profile_name_2","user_hierarchy_1|user_hierarchy_2","phone type (soft/desk)","phone number","soft phone auto accept (yes/no)","ACW timeout (seconds)","tags"

#collect required attributes
$r."first name" = $m.givenname
$r."last name" = $m.surname
$r."user login" = $m.userprincipalname
$r."routing profile name" = "Basic Routing Profile"
$r."security_profile_name_1|security_profile_name_2" = "Agent"
$r."ACW timeout (seconds)" = "0"
$r."phone type (soft/desk)" = "soft"
$r."soft phone auto accept (yes/no)" = "no"

$results += $r
"added user: $($m.displayname)"
}

"results collected: $($results.count)"
"exporting to connectusers.csv..."
$results | export-csv $exportFile -NoTypeInformation -QuoteFields 0

}else {"no members found. script exit"}
