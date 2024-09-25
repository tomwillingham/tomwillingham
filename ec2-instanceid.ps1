#!/usr/local/bin/pwsh

$IpAddress = $args[0]

# Run AWS CLI command to describe instances and store the output in a variable
$instanceInfo = (aws --profile saml ec2 describe-instances | ConvertFrom-Json )

# Define an array to store instance details
#$instances = @()
$instances = New-Object System.Collections.ArrayList

# Loop through each instance in the output
foreach ($reservation in $instanceInfo.Reservations) {

    #Write-Host "Processing Reservation $($instanceInfo.Reservations)"  -ForegroundColor Cyan

    foreach ($instance in $reservation.Instances) {
        # Create a custom object to store instance details
        $instanceDetails = [PSCustomObject]@{
            OwnerId            = $reservation.OwnerId
            InstanceId         = $instance.InstanceId
            InstanceType       = $instance.InstanceType
            State              = $instance.State.Name
            PrivateIpAddress   = $instance.PrivateIpAddress
            PublicIpAddress    = $instance.PublicIpAddress
            InstanceName       = $instance.Tags | ?{$_.Key -eq 'name' } | ForEach-Object { $_.Value }
            Platform           = $instance.PlatformDetails
            # Add more properties as needed
        }

        # Add the custom object to the array
        #$instances += $instanceDetails
        $instances.Add($instanceDetails)|Out-Null
    }
}

# Convert the array of objects into CSV format and output to a file
#$instances.GetEnumerator()| Export-Csv -Path "instance_details.csv" -NoTypeInformation
#$instances.GetEnumerator()| ConvertTo-Csv -NoTypeInformation
$instances.GetEnumerator() | ?{$_.PrivateIpAddress -eq $IpAddress} | ForEach-Object { $_.InstanceId }
#$instances.InstanceId | ?{$_.PrivateIpAddress -eq '10.146.255.184'} 
#$instances.InstanceId | fl
