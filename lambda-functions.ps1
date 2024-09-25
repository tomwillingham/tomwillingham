#!/usr/local/bin/pwsh


$instances = New-Object System.Collections.ArrayList
foreach ($ProfileName in Get-Content -Path ~/.aws/config | Where-Object { $_ -like '*profile*' } | Foreach-Object { $_ -replace "\[" -replace "\]" -replace "profile " }) {

    # Run AWS CLI command to describe instances and store the output in a variable
    $functionInfo = (aws --profile $ProfileName lambda list-functions | ConvertFrom-Json )

    # Loop through each instance in the output
    foreach ($functions in $functionInfo.Functions) {

            # Create a custom object to store instance details
            $instanceDetails = [PSCustomObject]@{
                FunctionName       = $functions.FunctionName
                FunctionARN        = $functions.FunctionARN
                Runtime            = $functions.Runtime
                # Add more properties as needed
            }

            # Add the custom object to the array
            #$instances += $instanceDetails
            $instances.Add($instanceDetails)|Out-Null
        }
    }

# Convert the array of objects into CSV format and output to a file
#$instances.GetEnumerator()| Export-Csv -Path "instance_details.csv" -NoTypeInformation
$instances.GetEnumerator()| ConvertTo-Csv -NoTypeInformation
#$instances.GetEnumerator() | ?{$_.State -eq 'stopped'}
#$instances.GetEnumerator() | ft
