#!/usr/local/bin/pwsh

# Run AWS CLI command to describe instances and store the output in a variable
$instanceInfo = (aws --profile saml ec2 describe-reserved-instances | ConvertFrom-Json )

# Define an array to store instance details
#$instances = @()
$instances = New-Object System.Collections.ArrayList

# Loop through each instance in the output
foreach ($reservation in $instanceInfo.ReservedInstances) {

    #Write-Host "Processing Reservation $($instanceInfo.Reservations)"  -ForegroundColor Cyan
        # Create a custom object to store instance details
        $instanceDetails = [PSCustomObject]@{
            ReservedInstancsID = $reservation.ReservedInstancesID
            AvailabillityZone  = $reservation.AvailabilityZone
            InstanceType       = $reservation.InstanceType
            InstanceCount      = $reservation.InstanceCount
            FixedPrice         = $reservation.FixedPrice
            ProductDescription = $reservation.ProductDescription
            State              = $reservation.State
            StartDate          = $reservation.Start
            EndDate            = $reservation.End
            OfferingType       = $reservation.OfferingType
            Platform           = $reservation.PlatformDetails
            Scope              = $reservation.Scope
            RecurringAmount    = $reservation.RecurringCharges.Amount
            RecurringFrequency = $reservation.RecurringCharges.Frequency
            # Add more properties as needed
        }

        # Add the custom object to the array
        #$instances += $instanceDetails
        $instances.Add($instanceDetails)|Out-Null
}

# Convert the array of objects into CSV format and output to a file
#$instances.GetEnumerator()| Export-Csv -Path "instance_details.csv" -NoTypeInformation
$instances.GetEnumerator()| ConvertTo-Csv -NoTypeInformation
#$instances.GetEnumerator() | ?{$_.State -eq 'stopped'}
#$instances.GetEnumerator() | ft
