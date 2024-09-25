#!/usr/local/bin/pwsh

# Define an array to store instance details
#$instances = @()
$instances = New-Object System.Collections.ArrayList

foreach ($ProfileName in Get-Content -Path ~/.aws/config | Where-Object { $_ -like '*profile*' } | Foreach-Object { $_ -replace "\[" -replace "\]" -replace "profile " }) {


    # Run AWS CLI command to describe instances and store the output in a variable
    $instanceInfo = (aws --profile $ProfileName ec2 describe-instances | ConvertFrom-Json )

    # Loop through each instance in the output
    foreach ($reservation in $instanceInfo.Reservations) {

        #Write-Host "Processing Reservation $($instanceInfo.Reservations)"  -ForegroundColor Cyan

        foreach ($instance in $reservation.Instances) {

            #Write-Host "Processing Reservation $($instanceInfo.Reservations)"  -ForegroundColor Cyan
            $Filters = @{                                                       
                Key="InstanceIds"
                Values=$instance.InstanceId
            }

            $ssminstanceInfo = (Get-SSMInstanceInformation -ProfileName $ProfileName -Filter $Filters)

            # Create a custom object to store instance details
            $instanceDetails = [PSCustomObject]@{
                OwnerId            = $reservation.OwnerId
                InstanceId         = $instance.InstanceId
                InstanceType       = $instance.InstanceType
                State              = $instance.State.Name
                PrivateIpAddress   = $instance.PrivateIpAddress
                IPv6Address        = $instance.NetworkInterfaces.Ipv6Addresses.Ipv6Address
                PublicIpAddress    = $instance.PublicIpAddress
                InstanceName       = $instance.Tags | ?{$_.Key -eq 'name' } | ForEach-Object { $_.Value }
                Backup             = $instance.Tags | ?{$_.Key -eq 'Backup' } | ForEach-Object { $_.Value }
                Application        = $instance.Tags | ?{$_.Key -eq 'Application' } | ForEach-Object { $_.Value }
                TechLead           = $instance.Tags | ?{$_.Key -eq 'Tech Lead' } | ForEach-Object { $_.Value }
                ComputerName       = $ssminstanceInfo.ComputerName
                PlatformName       = $ssminstanceInfo.PlatformName
                PlatformType       = $ssminstanceInfo.PlatformType
                PlatformVersion    = $ssminstanceInfo.PlatformVersion
                # Add more properties as needed
            }

            # Add the custom object to the array
            #$instances += $instanceDetails
            $instances.Add($instanceDetails)|Out-Null
    }
}
}

# Convert the array of objects into CSV format and output to a file
#$instances.GetEnumerator()| Export-Csv -Path "instance_details.csv" -NoTypeInformation
$instances | ConvertTo-Csv -NoTypeInformation
#$instances.GetEnumerator() | ?{$_.State -eq 'stopped'}
#$instances.GetEnumerator() | ft
