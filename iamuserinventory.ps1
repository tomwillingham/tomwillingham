#!/usr/local/bin/pwsh

#param (
#
#    [string]$ProfileName
#
#)
$users = New-Object System.Collections.ArrayList
foreach ($ProfileName in Get-Content -Path .aws/config | Where-Object { $_ -like '*profile*' } | Foreach-Object { $_ -replace "\[" -replace "\]" -replace "profile " }) {


    # Run AWS CLI command to describe instances and store the output in a variable
    $IAMUsersInfo = (Get-IAMUsers -ProfileName $ProfileName )

    $AWSAccount = (Get-IAMAccountAlias -ProfileName $ProfileName)

    # Define an array to store instance details
    $Now = Get-Date

    # Loop through each instance in the output
    foreach ($iamuser in $IAMUsersInfo) {

        foreach ($userAccesskey in (Get-IAMAccessKey -ProfileName $ProfileName -UserName $iamuser.UserName)) {
            # Create a custom object to store instance details
            $IAMUserDetail       = (Get-IAMUser -ProfileName $ProfileName -UserName $iamuser.UserName)
            $userDetails = [PSCustomObject]@{
                AWSAccount       = $AWSAccount 
                UserName         = $iamuser.UserName
                UserId           = $iamuser.UserId
                UserCreateDate   = ($iamuser.CreateDate).ToString("MM/dd/yyyy")
                PasswordLastUsed = ($iamuser.PasswordLastUsed).ToString("MM/dd/yyyy")
                KeyCreateDate    = ($userAccessKey.CreateDate).ToString("MM/dd/yyyy")
                AccessKeyLastUsed = ((Get-IAMAccessKeyLastUsed -ProfileName $ProfileName -AccessKeyId $userAccessKey.AccessKeyId ).AccessKeyLastUsed.LastUsedDate).ToString("MM/dd/yyyy")
                # Add more properties as needed
                KeyAge = (New-TimeSpan -Start (($userAccessKey.CreateDate).Date) -End $now).Days
                PointOfContact   = $IAMUserDetail.Tags | Where-Object {$_.Key -eq 'POC' } | ForEach-Object { $_.Value }
                EmailAddress     = $IAMUserDetail.Tags | Where-Object {$_.Key -eq 'Email' } | ForEach-Object { $_.Value }
            }

            # Add the custom object to the array
            $users.Add($userDetails)|Out-Null
        }
    }

}

# Convert the array of objects into CSV format and output to a file
$users | ConvertTo-Csv -NoTypeInformation

#$users 
